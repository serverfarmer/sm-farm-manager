# Server Farmer farm manager

### Overview

`sf-farm-manager` is one of the most important Server Farmer extensions, providing actual farm management scripts. Some scripts rely on other extension, mostly `sf-backup-collector` and `sf-keys`.

### management scripts

`add-managed-host.sh` - the most important script, used to add new hosts to the farm; it tries to connect to the added server for a few times using ssh, then creates dedicated ssh keys for `root` and `backup` users, and executes `add-backup-host.sh` script from `sf-backup-collector` extension

`add-dedicated-key.sh` - generates new ssh key and uploads it to managed host

`docker-rescan.sh` - scans the whole farm for hosts with installed Docker

### command execution scripts

`console.sh` - either connects to given host in console mode (with enabled terminal features), or executes given command on given host

`run.sh` - executes given local script on given remote host (by first copying into the same place in filesystem and then executing)

`execute.sh` - executes given command on many hosts in the farm; user can select, which ones exactly:
- `-ph` - physical servers
- `-vm` - virtual servers
- `-cl` - cloud instances
- `-lxc` - LXC containers
- `-wks` - workstations
- `-prb` - problematic hosts
- `-dck` - Docker containers
- `-vz` - OpenVZ containers

### virtual vs cloud servers

The difference between "virtual" and "cloud" servers is the assumption, that for virtual servers, you also manage the underlying physical server. Technically, there are no differences - it's just for planning operations that require downtime.

### what are problematic hosts

Some real-life servers cause more problems than others. For example, servers running critical production, single-instance services, with long and/or problematic service restarts. Or with outdated operating system version, without available updates, but still needed to be run because of some particular software. Or with any other reason, for which every single operation on them (software upgrade, configuration change etc.) must be carefully planned.

You can move such hosts to "problematic" group and avoid executing normal daily tasks on them with `execute.sh` script.

### LXC support

Server Farmer was primarily written to work on "classic" physical and virtual Linux instances. Now it also fully supports LXC containers, with only a few differences in backup scheme (see `sf-backup` repository documentation for details).

### Docker and OpenVZ support

Both Docker and OpenVZ are supported in quite different way than LXC. Docker and OpenVZ are treated as "passive" containers, which means that installing Server Farmer inside such containers is not supported and in most cases doesn't have any practical sense.

However, `execute.sh` script allows executing commands inside these containers - directly from farm manager, through parent host of each such container.

### `*.hosts` files

This extensions maintains a "database" consisting of a few `*.hosts` files located in `/etc/local/.farm` directory. These files can be divided into 2 groups:

1. `workstation.hosts`, `physical.hosts`, `virtual.hosts`, `cloud.hosts`, `lxc.hosts`, `problematic.hosts` - lists of active hosts, which can be directly managed.

2. `docker.hosts`, `openvz.hosts` - Docker/OpenVZ hosts, on which `execute.sh` should execute commands in `-dck` or `-vz` modes (these hosts must be also included in the first group, as managed hosts).

### `*.hosts` file format

`*.hosts` files are simply text files with list of hostnames, possibly including port numbers and project/customer tags (see below), one per line:

```
hostname1.internal:22:ourcompany:timeout
hostname2.internal::ourcompany
otherserver.domain.com:3322:customer1
```

Empty lines and lines starting with `#` character are ignored, so you can use them to better organize the contents, add comments etc.

Fields:
- hostname
- port (optional, default 22)
- tag (eg. client name)
- timeout in seconds (optional, default 60, used only by `execute.sh`, ignored for Docker/OpenVZ)

### project/customer tags and hook script

`console.sh`, `run.sh` and `execute.sh` scripts look for `/etc/local/hooks/ssh-accounting.sh` script and execute it if exists, each time you execute command using them: before and after actual command execution.

Hook script doesn't receive the executed command or hostname, instead it only receives `start` or `stop` arguments, and the project/customer tag (`ourcompany` or `customer1` in the above example), on which current command is executed.

Using this `/etc/local/hooks/ssh-accounting.sh` script you can gather some simple statistics: how many commands are executed for each project or customer, on how many servers, how long they last etc.
