# Share ZFS Datasets Via NFS/SMB

## NFS

```shell
sudo apt-get install -y nfs-kernel-server
```

### Simple Usage

```shell
zfs set sharenfs=on zfs-pool/dataset-tank
```
