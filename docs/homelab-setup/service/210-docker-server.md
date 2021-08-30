# Docker

## Services

1. linuxserver/homeassistant
2. linuxserver/jellyfin
3. linuxserver/nano-wallet
4. linuxserver/netbootxyz
5. linuxserver/qbittorrent
6. linuxserver/wikijs
7. linuxserver/tautulli
8. gotson/komga

## Setup

```bash
# install sid

# change ip address


# install docker
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```
