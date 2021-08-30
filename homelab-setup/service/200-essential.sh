#!/bin/bash

####################### VARIABLES

LXC_TEMPLATE=debian-10-standard_10.7-1_amd64.tar.gz
LXC_OS_TYPE=debian
LXC_HOSTNAME=essential
LXC_ID=200
LXC_CPU_CORE=2
LXC_MEMORY=512
LXC_SWAP=256

DOMAIN=domain.com
PROXY_ID=240
PROXY_DNS=198.18.0.2
SS_PASSWORD=asdfjklqwer-ourUHBeren_rejHDUEND-euejdne_YEHEBDUenhe29137EYEHDy48226hdbey782378


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
    groupadd -g 1802 labgroup &&\
    useradd -m -d /home/thunder -u 1802 -g labgroup -G mediagroup -s /bin/bash thunder &&\
    sudo -u thunder bash -c 'whoami' &&\
    echo 'Preconfig done.'"

####################### Gost Configuration

GOST_SYSTEMD_CONFIG =$(cat <<EOF
[Unit]
Description=Gost Proxy
After=network.target
Wants=network.target

[Service]
Type=simple
StandardError=journal
User=thunder
ExecStart=/usr/local/bin/gost -L=ss+otls://aes-256-gcm:$SS_PASSWORD@:8392
Restart=always

[Install]
WantedBy=multi-user.target
EOF
)

pct exec $LXC_ID -- cat -e $GOST_SYSTEMD_CONFIG >> /etc/systemd/system/gost.service

pct exec $LXC_ID -- wget https://github.com/ginuerzh/gost/releases/download/v2.11.1/gost-linux-amd64-2.11.1.gz
pct exec $LXC_ID -- gzip -d gost-linux-amd64-2.11.1.gz
pct exec $LXC_ID -- mv gost-linux-amd64-2.11.1 /usr/local/bin/gost
pct exec $LXC_ID -- chmod +x /usr/local/bin/gost
pct exec $LXC_ID -- systemctl enable gost.service
pct exec $LXC_ID -- systemctl start gost.service
pct exec $LXC_ID -- sysctl -w net.ipv4.ip_forward=1
pct exec $LXC_ID -- sysctl -p

####################### ACME.SH WildCard SSL Cert Configuration

pct exec $LXC_ID -- sudo --login -u thunder bash -ilc "cd ~ &&\
    git clone https://github.com/acmesh-official/acme.sh.git &&\
    cd ./acme.sh &&\
    ./acme.sh --install -m sidskang@gmail.com"

pct exec $LXC_ID -- sudo -u thunder bash -c '~/.acme.sh/acme.sh --home /mnt/acme --upgrade --auto-upgrade'
pct exec $LXC_ID -- sudo -u thunder bash -c '~/.acme.sh/acme.sh --home /mnt/acme --issue --dns dns_cf -d "*.$DOMAIN"'
pct exec $LXC_ID -- sudo -u thunder bash -c '~/.acme.sh/acme.sh --home /mnt/acme --issue --dns dns_cf -d "plex.$DOMAIN"'
pct exec $LXC_ID -- sudo -u thunder bash -c '~/.acme.sh/acme.sh --home /mnt/acme --toPkcs -d "*.$DOMAIN" --password pkcs_password'
pct exec $LXC_ID -- sudo -u thunder bash -c '~/.acme.sh/acme.sh --home /mnt/acme --toPkcs -d "plex.$DOMAIN" --password pkcs_password'

####################### Cleanup

pct set $LXC_ID -net0 name=eth0,bridge=vmbr0,firewall=0,gw=192.168.18.1,ip=192.168.18.$LXC_ID/24,type=veth
pct set $LXC_ID -nameserver 192.168.18.1
pct reboot $LXC_ID
