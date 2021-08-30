#!/bin/bash

####################### VARIABLES

LXC_TEMPLATE=debian-10-standard_10.7-1_amd64.tar.gz
LXC_OS_TYPE=debian
LXC_HOSTNAME=bt
LXC_ID=203
LXC_CPU_CORE=4
LXC_MEMORY=2048
LXC_SWAP=256

DOMAIN=domain.com
PROXY_ID=240
PROXY_DNS=198.18.0.2

#######################

pct create $LXC_ID store-image:vztmpl/debian-10-standard_10.7-1_amd64.tar.gz \
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

pct set $LXC_ID -mp0 /store/media,mp=/media
pct set $LXC_ID -mp1 /store/software/config/homelab/cert,mp=/mnt/acme
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
    useradd -m -d /home/media -u 1801 -g mediagroup -s /bin/bash media &&\
    sudo -u media bash -c 'whoami' &&\
    echo 'Preconfig done.'"

####################### Transmission Configuration

pct exec $LXC_ID -- bash -c "echo '' &&\
    apt install -y software-properties-common &&\
    add-apt-repository ppa:qbittorrent-team/qbittorrent-stable &&\
    apt update -y &&\
    apt install -y qbittorrent-nox"



QB_SYSTEMD_CONFIG=$(cat <<EOF
[Unit]
Description=qBittorrent Daemon Service
Documentation=man:qbittorrent-nox(1)
Wants=network-online.target
After=network-online.target nss-lookup.target
 
[Service]
# if you have systemd >= 240, you probably want to use Type=exec instead
Type=simple
User=media
ExecStart=/usr/bin/qbittorrent-nox
TimeoutStopSec=infinity
 
[Install]
WantedBy=multi-user.target
EOF
)

pct exec $LXC_ID -- cat -e $QB_SYSTEMD_CONFIG >> /etc/systemd/system/qbittorrent.service
pct exec $LXC_ID -- mkdir -p /home/media/.config/qBittorrent/
pct exec $LXC_ID -- systemctl daemon-reload
pct exec $LXC_ID -- systemctl enable qbittorrent.service
pct exec $LXC_ID -- systemctl start qbittorrent.service
pct exec $LXC_ID -- sysctl -w net.ipv4.ip_forward=1
pct exec $LXC_ID -- sysctl -p

####################### Cleanup

pct set $LXC_ID -net0 name=eth0,bridge=vmbr0,firewall=0,gw=192.168.18.1,ip=192.168.18.$LXC_ID/24,type=veth
pct set $LXC_ID -nameserver 192.168.18.1
pct reboot $LXC_ID
