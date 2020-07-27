# Prerequisites
You need to define everything in your `~/.ssh/config` before interact with this script.

# How-to
Running this command: `./ssh-jump ${DESTINATION_NODE} ${/path/to/IDENTITY_FILE}`
```bash
$ cat ~/.ssh/config
Host k8s-jumper
  HostName 127.0.0.1
  Port 2222
  User root

Host *.compute.internal
  User centos
  Port 22
  ProxyCommand ssh -q -W %h:%p k8s-jumper
  StrictHostKeyChecking no
.
.

$ ./ssh-jump.sh ip-10-0-30-61.ap-southeast-1.compute.internal /path/to/ssh-private-key.pem
Creating SSH jump host (Pod)...
pod/sshjump created
Forwarding from 127.0.0.1:2222 -> 22
Forwarding from [::1]:2222 -> 22
Handling connection for 2222
Warning: Permanently added 'ip-10-0-30-61.ap-southeast-1.compute.internal' (ECDSA) to the list of known hosts.
Last login: Mon Jul 27 03:06:36 2020 from ip-10-0-10-211.ap-southeast-1.compute.internal
[centos@ip-10-0-30-61 ~]$
.
.
.
[centos@ip-10-0-30-61 ~]$ logout
Connection to ip-10-0-30-61.ap-southeast-1.compute.internal closed.
warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
pod "sshjump" force deleted
```