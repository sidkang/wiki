# Plex-Media-Server

## Requirements

1. Cannot use wildcard certificate. Certificate Folder is `/mnt/acme/plex.$DOMAIN/plex.$DOMAIN.pfx`

## Config Script

```bash

--8<-- "{{ macros.snippet_full_path('204-plex.sh') }}"

```
