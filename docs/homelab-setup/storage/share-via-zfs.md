# Share ZFS Datasets Via NFS/SMB

## NFS

```shell
sudo apt-get install -y nfs-kernel-server
```

### Simple Usage

```shell
zfs set sharenfs=on zfs-pool/dataset-tank
```


## Reference

[Oracle ZFS Sharing](https://docs.oracle.com/cd/E23824_01/html/821-1448/gayne.html#NewZFSSharingSyntaxhttps://docs.oracle.com/cd/E23824_01/html/821-1448/gayne.html)