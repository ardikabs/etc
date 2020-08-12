# Prerequisites
1. This script ONLY tested in Linux environment<br>
  **TODO: Support MacOS and Windows**

# How-to
Running this command: `./ssh-jump ${DESTINATION_NODE} ${/path/to/IDENTITY_FILE} ${SSH_USER:-centos} ${SSH_PORT:-22}`
```
$ ./ssh-jump.sh ip-10-0-30-61.ap-southeast-1.compute.internal /path/to/ssh-private-key.pem
Creating SSH jump host (Pod)...
pod/sshjump-z80ursw created
Forwarding from 127.0.0.1:50183 -> 22
Forwarding from [::1]:50183 -> 22
Handling connection for 50183
Warning: Permanently added 'ip-10-0-30-61.ap-southeast-1.compute.internal' (ECDSA) to the list of known hosts.
Last login: Mon Jul 27 03:06:36 2020 from ip-10-0-10-211.ap-southeast-1.compute.internal
[centos@ip-10-0-30-61 ~]$
.
.
.
[centos@ip-10-0-30-61 ~]$ logout
Connection to ip-10-0-30-61.ap-southeast-1.compute.internal closed.
warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
pod "sshjump-z80ursw" force deleted
```