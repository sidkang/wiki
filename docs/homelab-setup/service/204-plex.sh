#!/bin/bash

####################### VARIABLES

LXC_TEMPLATE=ubuntu-21.04-standard_21.04-1_amd64.tar.gz
LXC_OS_TYPE=ubuntu
LXC_HOSTNAME=plex
LXC_ID=204
LXC_CPU_CORE=6
LXC_MEMORY=2048
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

pct set $LXC_ID -mp1 /store/media,mp=/media
pct set $LXC_ID -mp2 /store/software/config/homelab/cert,mp=/mnt/acme
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
    sed -i 's|http://archive.ubuntu.com/ubuntu|https://mirrors.tuna.tsinghua.edu.cn/ubuntu/|g' /etc/apt/sources.list &&\
    apt update -y &&\
    apt upgrade -y --no-install-recommends &&\
    apt install -y sudo curl git gnupg2 &&\
    echo 'LC_ALL=en_US.UTF-8' | sudo tee -a /etc/environment > /dev/null &&\
    echo 'en_US.UTF-8 UTF-8' | sudo tee -a /etc/locale.gen > /dev/null &&\
    echo 'LANG=en_US.UTF-8' | sudo tee /etc/locale.conf > /dev/null &&\
    sudo locale-gen en_US.UTF-8"

pct exec $LXC_ID -- bash -c "echo &&\
    groupadd -g 1801 plex &&\
    useradd -m -d /home/plex -u 1801 -g plex -s /bin/bash plex &&\
    sudo -u plex bash -c 'whoami' &&\
    echo 'Preconfig done.'"
pct exec $LXC_ID -- bash -c "echo &&\
    echo deb https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list &&\
    curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add - &&\
    apt update -y &&\
    apt install -y plexmediaserver"

####################### Cleanup

pct set $LXC_ID -net0 name=eth0,bridge=vmbr0,firewall=0,gw=192.168.18.1,ip=192.168.18.$LXC_ID/24,type=veth
pct set $LXC_ID -nameserver 192.168.18.1
pct reboot $LXC_ID
