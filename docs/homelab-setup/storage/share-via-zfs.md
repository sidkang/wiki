# Share ZFS Datasets Via NFS/SMB

## NFS

```shell
# Install nfs server
sudo apt-get install -y nfs-kernel-server

# Simple Usage
zfs set sharenfs=on zfs-pool/dataset-tank
```

##### Advanced Example

```shell
# Using NFSv3, you can add UID & GID setting to the sharenfs command.
zfs set sharenfs="async,anonuid=$UID,anongid=$GID,rw=192.168.18.0/24" zfs-pool/dataset-tank
# To give different options per IP.
zfs set sharenfs="root_squash,rw=192.168.1.216,ro=192.168.1.0/24" zfs-pool/dataset-tank

# BAD EXAMPLE
zfs set sharenfs="root_squash,rw=192.168.1.216,all_squash,ro=192.168.1.0/24" zfs-pool/dataset-tank
### the `all_squash` param in the example above takes no effects.
```

@ symbol is only useful when using partial ip addresses. In other words, `192.168.1.0/24` and `@192.168.1` are equivalent.

## SMB

```shell
apt-get install -y samba
```

## Reference

[Oracle ZFS Sharing](https://docs.oracle.com/cd/E23824_01/html/821-1448/gayne.html#NewZFSSharingSyntaxhttps://docs.oracle.com/cd/E23824_01/html/821-1448/gayne.html)

[Sharenfs Option Issue](https://github.com/openzfs/zfs/issues/3860)