#!/bin/bash

####################### VARIABLES

LXC_TEMPLATE=debian-10-standard_10.7-1_amd64.tar.gz
LXC_OS_TYPE=debian
LXC_HOSTNAME=webdav
LXC_ID=201
LXC_CPU_CORE=2
LXC_MEMORY=512
LXC_SWAP=256

PROXY_ID=240
PROXY_DNS=198.18.0.2

#######################

pct create $LXC_ID store-image:vztmpl/$LXC_TEMPLATE \
    --unprivileged 1 \
    --hostname $LXC_HOSTNAME \
    --ssh-public-keys ~/.ssh/id_rsa_new.pub \
    --rootfs spool-vm:16 \
    --ostype $LXC_OS_TYPE \
    --arch amd64 \
    --cores $LXC_CPU_CORE \
    --cpulimit 0 \
    --cpuunits 1024 \
    --memory $LXC_MEMORY \
    --swap $LXC_SWAP \
    --net0 name=eth0,bridge=vmbr0,firewall=0,gw=192.168.18.$PROXY_ID,ip=192.168.18.$LXC_ID/24,type=veth \
    --nameserver $PROXY_DNS \
    --onboot 1 \
    --startup order=1

pct set $LXC_ID -mp1 /store/media,mp=/mnt/media
pct set $LXC_ID -mp2 /store/document,mp=/mnt/document
pct set $LXC_ID -mp3 /store/software/sync,mp=/mnt/sync
echo -e "
lxc.idmap = u 0 100000 1801
lxc.idmap = g 0 100000 1801
lxc.idmap = u 1801 1801 3
lxc.idmap = g 1801 1801 3
lxc.idmap = u 1804 101804 63732
lxc.idmap = g 1804 101804 63732
" >> /etc/pve/lxc/$LXC_ID.conf

####################### Boot, upgrade, UID & GID

pct start $LXC_ID
pct exec $LXC_ID -- bash -c "echo 'Preconfig' &&\
    sed -i 's|http://ftp.debian.org/debian|https://mirrors.tuna.tsinghua.edu.cn/debian/|g' /etc/apt/sources.list &&\
    sed -i 's|http://security.debian.org|https://mirrors.tuna.tsinghua.edu.cn/debian-security|g' /etc/apt/sources.list &&\
    apt update -y &&\
    apt upgrade -y --no-install-recommends &&\
    apt install -y sudo curl git &&\
    rm -rf /etc/localtime &&\
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
    echo 'LC_ALL=en_US.UTF-8' | sudo tee -a /etc/environment > /dev/null &&\
    echo 'en_US.UTF-8 UTF-8' | sudo tee -a /etc/locale.gen > /dev/null &&\
    echo 'LANG=en_US.UTF-8' | sudo tee /etc/locale.conf > /dev/null &&\
    sudo locale-gen en_US.UTF-8"
pct exec $LXC_ID -- bash -c "echo &&\
    groupadd -g 1801 mediagroup &&\
    groupadd -g 1802 labgroup &&\
    useradd -m -d /home/media -u 1801 -g mediagroup -s /bin/bash media &&\
    useradd -m -d /home/thunder -u 1802 -g labgroup -G mediagroup -s /bin/bash thunder &&\
    sudo -u thunder bash -c 'whoami' &&\
    echo 'Preconfig done.'"

####################### Basic Setup

pct start $LXC_ID


####################### Webdav Server

WEBDAV_CONFIG=$(cat <<EOF
# Server related settings
address: 0.0.0.0
port: 443
auth: true
tls: true
cert: cert_file
key: key_file
prefix: /

# Default user settings (will be merged)
scope: /mnt
modify: true
rules: []

# CORS configuration
cors:
  enabled: true
  credentials: true
  allowed_headers:
    - Depth
  allowed_hosts:
    - http://localhost:443
  allowed_methods:
    - GET
  exposed_headers:
    - Content-Length
    - Content-Range

users:
  - username: media
    password: password
    scope: /mnt/media
  - username: sid
    password: password
    scope: /mnt/document
EOF
)
pct exec $LXC_ID -- mkdir /etc/webdav
pct exec $LXC_ID -- cat -e $WEBDAV_CONFIG >> /etc/webdav/config.yaml

WEBDAV_SYSTEMD=$(cat <<EOF
[Unit]
Description=WebDAV server
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/webdav --config /etc/config/webdav.yaml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
)
pct exec $LXC_ID -- cat -e $WEBDAV_SYSTEMD >> /etc/systemd/system/webdav.service

####################### Need to further modify

pct exec $LXC -- bash -c "echo '' &&\
    wget https://github.com/hacdias/webdav/releases/latest/download/linux-amd64-webdav.tar.gz &&\
    tar -xzvf linux-amd64-webdav.tar.gz &&\
    mv -f webdav /usr/lcocal/bin/ &&\
    sudo chmod +x /usr/local/bin/webdav"

pct exec $LXC -- bash -c "setcap 'cap_net_bind_service=+ep' /usr/local/bin/webdav &&\  
    `# enable <1024 port for specific program with unprivilieged user` &&\
    /sbin/sysctl -w net.ipv4.ip_unprivileged_port_start=0"

pct exec $LXC -- bash -c "systemctl enable webdav.service &&\
    systemctl start webdav.service"

####################### Cleanup

pct set $LXC_ID -net0 name=eth0,bridge=vmbr0,firewall=0,gw=192.168.18.1,ip=192.168.18.$LXC_ID/24,type=veth
pct set $LXC_ID -nameserver 192.168.18.1
pct reboot $LXC_ID
