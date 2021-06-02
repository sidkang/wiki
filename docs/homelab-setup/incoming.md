1. redirect proxmox web ui port from 8006 to 443

```bash
iptables -F
iptables -t nat -F
iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 8006
```
