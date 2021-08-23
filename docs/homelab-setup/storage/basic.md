# Basic Storage Setup

## ZFS Commands

```shell
zpool create -f -o ashift=12 <pool> <device1> <device2>
zpool create -f -o ashift=12 <pool> mirror <device1> <device2>
zpool create -f -o ashift=12 <pool> mirror <device1> <device2> mirror <device3> <device4>
zpool create -f -o ashift=12 <pool> raidz1 <device1> <device2> <device3>

zpool replace -f <pool> <old device> <new device>

zfs snapshot poolA/dataset@migrate
zfs send -vR poolA/dataset@migrate | zfs recv poolB/dataset
zfs set compression=zstd zfs-pool/dataset-store
```

## Storage Configuration

Currently, I've 6 SSDs and 4 HDDs attached to the server.

```bash
## 2 sata ssd is the host system disk (already done)
## NVME MIRROR for VM usage
zpool create -f -o ashift=12 npool mirror /dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NF0R141636 /dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NF0R200364
zfs set compression=zstd npool
zfs set atime=off npool
zfs set recordsize=16K npool
## SATA SSD MIRROR for high performance usage
zpool create -f -o ashift=12 spool mirror /dev/disk/by-id/ata-CT2000MX500SSD1_2117E5996F05 /dev/disk/by-id/ata-CT2000MX500SSD1_2117E5997C0B

zfs set compression=zstd spool

zfs create spool/vm
zfs create spool/document
zfs create spool/cache


zfs set atime=off recordsize=16K spool/vm
zfs set recordsize=16K spool/cache

zfs create store/software
zfs set atime=off recordsize=1M store/software
zfs create store/software/image
zfs create store/software/config
zfs set atime=on recordsize=16K store/software/config
zfs create store/software/developer
zfs set atime=on recordsize=16K store/software/developer
zfs create store/software/sync
zfs set atime=on recordsize=16K store/software/sync
```

### Add PVE Storage

```bash
pvesm add zfspool <storage-ID> -pool <pool-name>
pvesm add dir <STORAGE_ID> --path <PATH>

## disable default storage
pvesm set local --disable 1
pvesm set local-zfs --disable 1
##
pvesm add zfspool npool-vm -pool npool
pvesm set npool-vm --content images,rootdir
pvesm add zfspool spool-vm -pool spool/vm
pvesm set spool-vm --content images,rootdir
## the thin-provision setting cannot be set by api command.
pvesm add dir store-image --path '/store/software/image'
pvesm set store-image --content  iso,vztmpl
```

```bash

```

## config user & group

```bash
groupadd -g 1801 mediagroup
groupadd -g 1802 labgroup
groupadd -g 1803 sidgroup
```

```bash
# Create User media
useradd -m -d /home/media -u 1801 -g mediagroup -s /bin/bash media
# Create User storm
useradd -m -d /home/thunder -u 1802 -g labgroup -G mediagroup -s /bin/bash thunder
# Create User sid
useradd -m -d /home/sid -u 1803 -g sidgroup -G mediagroup,labgroup -s /bin/bash sid
# the below commands only need to excute once on the host system
grep -qxF 'root:1801:3' /etc/subuid || echo 'root:1801:3' >> /etc/subuid
grep -qxF 'root:1801:3' /etc/subgid || echo 'root:1801:3' >> /etc/subgid
```

!!! note "SAMPLE ID MAP FOR LXCs"
    ```
    lxc.idmap = u 0 100000 1801
    lxc.idmap = g 0 100000 1801
    lxc.idmap = u 1801 1801 3
    lxc.idmap = g 1801 1801 3
    lxc.idmap = u 1804 101804 63732
    lxc.idmap = g 1804 101804 63732
    ```

## Apt, Update & Upgrade

```bash
echo "deb https://mirrors.tuna.tsinghua.edu.cn/proxmox/debian bullseye pve-no-subscription" >> /etc/apt/sources.list.d/pve-no-subscription.list

sed -i '1s/^/# /' /etc/apt/sources.list.d/pve-enterprise.list

sed -i 's|http://ftp.debian.org/debian|https://mirrors.tuna.tsinghua.edu.cn/debian/|g' /etc/apt/sources.list
sed -i 's|http://security.debian.org|https://mirrors.tuna.tsinghua.edu.cn/debian-security|g' /etc/apt/sources.list

apt update && apt upgrade && apt install openvswitch-switch
```

## Download Essential LXC Template

```bash
cp /usr/share/perl5/PVE/APLInfo.pm /usr/share/perl5/PVE/APLInfo.pm_back
sed -i 's|http://download.proxmox.com|https://mirrors.tuna.tsinghua.edu.cn/proxmox|g' /usr/share/perl5/PVE/APLInfo.pm

pveam update
pveam download store-image debian-11-standard_11.0-1_amd64.tar.gz
pveam download store-image ubuntu-20.04-standard_20.04-1_amd64.tar.gz
pveam download store-image ubuntu-21.04-standard_21.04-1_amd64.tar.gz
```

## Manual Setup SSL Cert

```bash
cp /store/software/config/homelab/cert/\*.domain.com/fullchain.cer /etc/pve/local/pveproxy-ssl.pem
cp /store/software/config/homelab/cert/\*.domain.com/\*.domain.com.key /etc/pve/local/pveproxy-ssl.key
systemctl restart pveproxy
```
