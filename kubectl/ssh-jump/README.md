# Disclaimer
This script is a simple bash script and expect to run with `ss` command for Linux/GNU OS. Other than Linux/GNU OS, this script will randomized port between `49152 - 59152` to be used without any check, so it is expected in case picked port is already on used then script would be exit with non-zero status code and you need to re-run the script.

# Prerequisites
1. Clone this repository
1. Move `ssh-jump` to `/usr/local/bin`
1. Enjoy
```bash
$ git clone https://github.com/ardikabs/etc.git
$ mv etc/k8s-ssh-jump/ssh-jump /usr/local/bin/
$ ssh-jump
```

# How-to
## Usage
```bash
$ ssh-jump --help
ssh-jump is a command line tool for ssh'ing to an instance under kubernetes host private networks

Usage:
    ssh-jump [flags] TARGET_NODE

Examples:

    # Use ssh key from selected file
    ssh-jump -i ~/.ssh/id_rsa ip-10-0-10-217.ap-southeast-1.compute.internal

    # Use ssh private key from ssh-agent
    ssh-jump ip-10-0-10-217.ap-southeast-1.compute.internal

Flags:
  -h, --help          : show this message
  -u, --username      : Target SSH username. Default "centos".
  -p, --port          : Target SSH Port. Default "22".
  -i, --identity-file : Target SSH identity file.
  -o, --ssh-opts      : SSH additional flags.
  --cleanup           : Clean up ssh-jump if any. This flag is mutually exclusive with "--persistent".
  --persistent        : Enable ssh-jump pod in persistent mode. This flag is mutually exclusive with "--cleanup".
```

## SSH'ing to the target node
```
$ ssh-jump -i /path/to/ssh-private-key.pem ip-10-0-30-61.ap-southeast-1.compute.internal
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
Terminating pod/sshjump-z80ursw
pod "sshjump-z80ursw" force deleted
```

## Enable ssh-jump persistent mode
```
$ ssh-jump --persistent -i /path/to/ssh-private-key.pem ip-10-0-30-61.ap-southeast-1.compute.internal
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

# Try it again
# You will using existing ssh-jump as a jumper
$ ssh-jump -i /path/to/ssh-private-key.pem ip-10-0-30-61.ap-southeast-1.compute.internal
Use existing SSH jump host (sshjump-z80ursw)
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

# Cleanup ssh-jump
$ ssh-jump --cleanup -i /path/to/ssh-private-key.pem ip-10-0-30-61.ap-southeast-1.compute.internal
Use existing SSH jump host (sshjump-z80ursw)
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
Terminating pod/sshjump-z80ursw
pod "sshjump-z80ursw" force deleted
```