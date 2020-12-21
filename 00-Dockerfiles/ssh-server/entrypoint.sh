#!/bin/bash

set -e

username=${SSH_USERNAME:-ubuntu}
password=${SSH_PASSWORD:-!1Password}

useradd -rm -d /home/"${username}" -s /bin/bash -g root -G sudo -u 1001 "${username}"
echo "${username}:${password}" | chpasswd

if [ "$1" = 'ssh-server' ]
then
    exec /usr/sbin/sshd -D
fi

exec "$@"