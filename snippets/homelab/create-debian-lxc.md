```bash
pct create {{ page.meta.vmid }} store-image:vztmpl/debian-11-standard_11.0-1_amd64.tar.gz \
    --unprivileged 1 `# default value` \
    --hostname {{ page.meta.hostname }} \
    --ssh-public-keys ~/.ssh/id_rsa_new.pub `#use public ssh key` \
    --rootfs spool-vm:16  `#16G for the startup disk` \
    --ostype debian  `#match with the container system, such as Debian, Ubuntu, Opensuse ...` \
    --arch amd64  `# default value` \
    --cores {{ page.meta.cpu_core }} \
    --cpulimit 0 \
    --cpuunits 1024 \
    --memory {{ page.meta.memory }} \
    --swap {{ page.meta.swap }} \
    `#for futher convienence, last ip digit same as ct id` \
    --net0 name=eth0,bridge=vmbr0,firewall=0,gw=192.168.18.55,ip=192.168.18.{{ page.meta.vmid }}/24,type=veth \
    --nameserver 198.18.0.2 \
    --onboot 1  `# boot on create, 1 -> True, 0 -> False` \
    --startup order=1
```