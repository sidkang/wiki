
groupadd -g 1604 medialab
groupadd -g 1605 lab
groupadd -g 1606 sidslab

# Create User media
useradd -m -d /home/media -u 1604 -g medialab -s /bin/bash media
# Create User storm
useradd -m -d /home/storm -u 1605 -g lab -G medialab -s /bin/bash storm
# Create User sid
useradd -m -d /home/sids -u 1606 -g sidslab -G medialab,lab -s /bin/bash sids

# uid map: from uid 0 map 1005 uids (in the ct) to the range starting 100000 (on the host), so 0..1004 (ct) → 100000..101004 (host)
lxc.idmap = u 0 100000 1606
lxc.idmap = g 0 100000 1606
# we map 1 uid starting from uid 1005 onto 1005, so 1005 → 1005
lxc.idmap = u 1606 1606 1
lxc.idmap = g 1606 1606 1
# we map the rest of 65535 from 1006 upto 101006, so 1006..65535 → 101006..165535
lxc.idmap = u 1607 101607 63929
lxc.idmap = g 1607 101607 63929
