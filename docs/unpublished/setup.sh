

groupadd -g 1604 mediagroup
groupadd -g 1605 homegroup
groupadd -g 1606 sidsgroup

# Create User media
useradd -m -d /home/media -u 1604 -g medialab -s /bin/bash media
# Create User storm
useradd -m -d /home/storm -u 1605 -g lab -G medialab -s /bin/bash storm
# Create User sid
useradd -m -d /home/sids -u 1606 -g sidslab -G medialab,lab -s /bin/bash sids

# uid map: from uid 0 map 1604 uids (in the ct) to the range starting 100000 (on the host), so 0..1004 (ct) → 100000..101004 (host)
lxc.idmap = u 0 100000 1604
lxc.idmap = g 0 100000 1604
# we map 3 uid starting from uid 1604 onto 1604
lxc.idmap = u 1604 1604 3
lxc.idmap = g 1604 1604 3
# we map the rest of 65535 from 1607 upto 101607, and number count is 65536 - 1604 - 3
lxc.idmap = u 1607 101607 63929
lxc.idmap = g 1607 101607 63929



# User storm | Group homelab
grep -qxF 'root:1606:1' /etc/subuid || echo 'root:1606:1' >> /etc/subuid
grep -qxF 'root:100:1' /etc/subgid || echo 'root:100:1' >> /etc/subgid
