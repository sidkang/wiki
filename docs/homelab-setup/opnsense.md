# OPNsense

## 配置过程

## Cron Jobs

### Create new configd action

```bash
cd cd /usr/local/opnsense/service/conf/actions.d
```

Create a file with the name actions_NAME.conf, where NAME is something meaningful to the task.

```shell
# actions_wol.conf
[wake]
command:/usr/local/bin/wol -i
parameters: %s %s
type:script
description:Wake-On-LAN for host with broadcast IP and MAC
message:Waking up host %s %s

# actions_cron.conf
[restart]
command:pluginctl -s cron restart
parameters:
type:script
message:restarting cron
description:Restart Cron service
```

```bash
configctl wol wake abc def
configctl updatedns reload
```

The log files are stored in /var/log/configd.log

## Userful Commands

```shell
# reboot interface
configctl interface reconfigure <interface_name> && dhclient <interface_name> && configctl interface newip <interface_name>
configctl interface linkup stop <interface> && configctl interface reconfigure <interface> && configctl interface linkup start <interface>
```
