sf-farm-manager extension provides a simple solution for executing the same
command on all servers in a farm, or only on servers of given type (virtual,
physical, OpenVZ containers, in future also LXC/Docker containers).

add-managed-host.sh script performs automatic analysis of given host and
adds it to proper /etc/local/.config/*.hosts files on central server.


**Why sf-farm-manager instead of many other similar solutions?**

- integrated server farm management across core SF and all extensions
- ability to execute command only on particular servers, eg. OpenVZ containers
- simple, fast and lightweight
- no external dependencies (except SF itself)
