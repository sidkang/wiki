# QB ARCH LXC

```bash
pct create 203 tank-image:vztmpl/debian-10-standard_10.7-1_amd64.tar.gz \
    --unprivileged 1 `# default value` \
    --hostname qb \
    --ssh-public-keys ~/.ssh/id_rsa_new.pub \
    --rootfs spool-vm:16  `#16G for the startup disk` \
    --ostype debian  `#match with the container system, such as Debian, Ubuntu, Opensuse ...` \
    --arch amd64  `# default value` \
    --cores 4 \
    --cpulimit 0 \
    --cpuunits 1024 \
    --memory 2048 \
    --swap 256 \
    `#for futher convienence, last ip digit same as ct id` \
    --net0 name=eth0,bridge=vmbr0,firewall=0,gw=192.168.18.1,ip=192.168.18.203/24,type=veth \
    --mp0 /tank/media,mp=/mnt/media  `#mount specific folder from host to guest` \
    --onboot 1  `# boot on create, 1 -> True, 0 -> False` \
    --startup order=1
```

```bash
echo -e "
lxc.idmap = u 0 100000 1801
lxc.idmap = g 0 100000 1801
lxc.idmap = u 1801 1801 3
lxc.idmap = g 1801 1801 3
lxc.idmap = u 1804 101804 63732
lxc.idmap = g 1804 101804 63732" >> /etc/pve/lxc/203.conf

pct start 203
pct exec 203 -- bash -c "echo 'Job begin.' &&\
    sed -i 's|http://ftp.debian.org/debian|https://mirrors.tuna.tsinghua.edu.cn/debian/|g' /etc/apt/sources.list &&\
    sed -i 's|http://security.debian.org|https://mirrors.tuna.tsinghua.edu.cn/debian-security|g' /etc/apt/sources.list &&\
    apt update -y &&\
    apt upgrade -y --no-install-recommends &&\
    apt install -y sudo curl git qbittorrent-nox &&\
    echo 'LC_ALL=en_US.UTF-8' | sudo tee -a /etc/environment > /dev/null &&\
    echo 'en_US.UTF-8 UTF-8' | sudo tee -a /etc/locale.gen > /dev/null &&\
    echo 'LANG=en_US.UTF-8' | sudo tee /etc/locale.conf > /dev/null &&\
    sudo locale-gen en_US.UTF-8 &&\
    groupadd -g 1801 mediagroup &&\
    groupadd -g 1802 labgroup &&\
    useradd -m -d /home/media -u 1801 -g mediagroup -s /bin/bash media &&\
    sudo -u media bash -c 'whoami' &&\
    echo 'Job done.'"
```

```systemd
[Unit]
Description=qBittorrent Command Line Client
After=network.target

[Service]
Type=forking
User=media
Group=mediagroup
UMask=007
ExecStart=/usr/bin/qbittorrent-nox -d --webui-port=8090
Restart=on-failure

[Install]
WantedBy=multi-user.target
```