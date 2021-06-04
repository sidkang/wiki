# Share ZFS Datasets Via NFS/SMB

## NFS

```shell
sudo apt-get install -y nfs-kernel-server
```

### Simple Usage

```shell
zfs set sharenfs=on zfs-pool/dataset-tank
```

### Advanced Example

To give different options per IP

```shell
zfs set sharenfs="root_squash,rw=192.168.1.216,ro=192.168.1.0/24" zfs-pool/dataset-tank
```

@ symbol is only useful when using partial ip addresses. In other words, `192.168.1.0/24` and `@192.168.1` are equivalent.

## Reference

[Oracle ZFS Sharing](https://docs.oracle.com/cd/E23824_01/html/821-1448/gayne.html#NewZFSSharingSyntaxhttps://docs.oracle.com/cd/E23824_01/html/821-1448/gayne.html)

[Sharenfs Option Issue](https://github.com/openzfs/zfs/issues/3860)