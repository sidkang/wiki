#!/bin/bash

####################### VARIABLES

LXC_TEMPLATE=debian-10-standard_10.7-1_amd64.tar.gz
LXC_OS_TYPE=debian
LXC_HOSTNAME=docker-basic
LXC_ID=205
LXC_CPU_CORE=4
LXC_MEMORY=3072
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

pct set $LXC_ID --features keyctl=1,nesting=1

pct set $LXC_ID -mp1 /store/media,mp=/media
pct set $LXC_ID -mp2 /store/software/config/homelab/cert,mp=/mnt/acme
pct set $LXC_ID -mp3 /store/software/docker/basic,mp=/mnt/docker
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
    apt install -y sudo curl git gnupg2 apt-transport-https ca-certificates lsb-release &&\
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
pct exec $LXC_ID -- bash -c "echo &&\
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg &&\
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null &&\
    curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add - &&\
    apt update -y &&\
    apt install -y docker-ce docker-ce-cli containerd.io &&\
    usermod -aG docker thunder"

####################### Cleanup

# pct set $LXC_ID -net0 name=eth0,bridge=vmbr0,firewall=0,gw=192.168.18.1,ip=192.168.18.$LXC_ID/24,type=veth
# pct set $LXC_ID -nameserver 192.168.18.1
pct reboot $LXC_ID




## komga

docker create \
  --name=komga \
  --user 1801:1801 \
  -p 8080:8080 \
  --mount type=bind,source=/mnt/docker/komga,target=/config \
  --mount type=bind,source=/media/manga,target=/data \
  --restart unless-stopped \
  gotson/komga