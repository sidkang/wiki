#!/bin/bash


VM_ID=215


##############################

qm create $VM_ID

qm create 104 \
    --cdrom local:iso/debian-10.2.0-amd64-netinst.iso \
    --name demo \
    --net0 virtio,bridge=vmbr0 \
    --virtio0 local:10,format=qcow2 \
    --arch x86_64 \
    --bootdisk virtio0 \
    --ostype l26 \
    --memory 1024 \
    --balloon 1 \
    --onboot no \
    --sockets 1