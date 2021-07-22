# Basic Storage Setup

## My Setup

Currently, I've 6 SSDs attached to the server.

## ZFS Commands

```shell
zpool create -f -o ashift=12 <pool> <device1> <device2>
zpool create -f -o ashift=12 <pool> mirror <device1> <device2>
zpool create -f -o ashift=12 <pool> mirror <device1> <device2> mirror <device3> <device4>
zpool create -f -o ashift=12 <pool> raidz1 <device1> <device2> <device3>

zpool replace -f <pool> <old device> <new device>

zfs snapshot poolA/dataset@migrate
zfs send -vR poolA/dataset@migrate | zfs recv poolB/dataset
zfs set compression=zstd zfs-pool/dataset-tank
```
