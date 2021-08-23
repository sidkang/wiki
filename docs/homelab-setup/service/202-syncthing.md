# Syncthing LXC

## Container Config

```bash
pct create 202 store-image:vztmpl/debian-10-standard_10.7-1_amd64.tar.gz \
    --unprivileged 1 `# default value` \
    --hostname SyncServer \
    --ssh-public-keys ~/.ssh/id_rsa_new.pub \
    --rootfs spool-vm:16  `#16G for the startup disk` \
    --ostype debian  `#match with the container system, such as Debian, Ubuntu, Opensuse ...` \
    --arch amd64  `# default value` \
    --cores 2 \
    --cpulimit 0 \
    --cpuunits 1024 \
    --memory 512 \
    --swap 256 \
    `#for futher convienence, last ip digit same as ct id` \
    --net0 name=eth0,bridge=vmbr0,firewall=0,gw=192.168.18.55,ip=192.168.18.202/24,type=veth \
    -nameserver 198.18.0.2 \
    --mp0 /store/software/config,mp=/mnt/config  `#mount specific folder from host to guest` \
    --mp1 /store/software/developer,mp=/mnt/developer \
    --mp2 /store/software/sync,mp=/mnt/sync \
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
lxc.idmap = g 1804 101804 63732" >> /etc/pve/lxc/202.conf
```

```bash
pct start 202
pct exec 202 -- bash -c "echo 'Job begin.' &&\
    sed -i 's|http://ftp.debian.org/debian|https://mirrors.tuna.tsinghua.edu.cn/debian/|g' /etc/apt/sources.list &&\
    sed -i 's|http://security.debian.org|https://mirrors.tuna.tsinghua.edu.cn/debian-security|g' /etc/apt/sources.list &&\
    apt update -y &&\
    apt upgrade -y --no-install-recommends &&\
    apt install -y sudo curl git apt-transport-https gnupg2 &&\
    sudo rm -rf /etc/localtime &&\
    sudo ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
    echo 'LC_ALL=en_US.UTF-8' | sudo tee -a /etc/environment > /dev/null &&\
    echo 'en_US.UTF-8 UTF-8' | sudo tee -a /etc/locale.gen > /dev/null &&\
    echo 'LANG=en_US.UTF-8' | sudo tee /etc/locale.conf > /dev/null &&\
    sudo locale-gen en_US.UTF-8"
pct exec 202 -- bash -c "echo 'Begin' &&\
    groupadd -g 1801 mediagroup &&\
    groupadd -g 1802 labgroup &&\
    groupadd -g 1803 sidgroup &&\
    useradd -m -d /home/sid -u 1802 -g sidgroup -G labgroup,mediagroup -s /bin/bash sid &&\
    sudo curl -s -o /usr/share/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg &&\
    echo 'deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable' | sudo tee /etc/apt/sources.list.d/syncthing.list &&\
    printf 'Package: *\nPin: origin apt.syncthing.net\nPin-Priority: 990\n' | sudo tee /etc/apt/preferences.d/syncthing &&\
    apt update -y &&\
    apt install -y syncthing &&\
    sudo -u sid bash -c 'whoami' &&\
    systemctl enable syncthing@sid.service &&\
    systemctl start syncthing@sid.service &&\
    echo 'Job done.'"
pct exec 202 -- bash -c "sed -i 's|127.0.0.1:8384|0.0.0.0:8384|g' /home/sid/.config/syncthing/config.xml &&\
    systemctl restart syncthing@sid.service"
```

```bash
# execute on pve host
pct set 202 -net0 name=eth0,bridge=vmbr0,firewall=0,gw=192.168.18.1,ip=192.168.18.202/24,type=veth
pct set 202 -nameserver 192.168.18.1
pct reboot 202
```
