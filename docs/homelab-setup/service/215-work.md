# Win-Workstation

## Services

## Requirements

## Config Script

```bash

--8<-- "{{ macros.snippet_full_path('215-work.sh') }}"

```

## Further Config

1. Install virt-io drivers
2. Install scoop


```bash
iwr -useb get.scoop.sh | iex
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
scoop install git
scoop bucket add extras
scoop install python vscode pyenv
```