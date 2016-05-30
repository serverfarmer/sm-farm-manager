sf-farm-manager extension provides several management scripts, allowing:

- registering new hosts with Server Farmer installed as managed by the same
  management server
- executing the same command on all servers in a farm, or only on servers of
  given type (virtual, physical, OpenVZ containers, in future also LXC/Docker
  containers)
- connecting to remote server console using ssh key without typing the key
  name or non-standard ssh port
- creating dedicated ssh keys for given user@host and automatically installing
  such keys
