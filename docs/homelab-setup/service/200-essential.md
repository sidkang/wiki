# Essential

## Services

1. Wildcard Cert issuement with ACME.SH via CF
2. Gost Proxy for Back Home Tunnel Service

## Requirements

1. Copy public ssh key to pve host with name 'id_rsa_new.pub'
2. Forward a port from WAN to 192.168.18.LXC_ID:8392

## Config Script

```bash

--8<-- "{{ macros.snippet_full_path('200-essential.sh') }}"

```
