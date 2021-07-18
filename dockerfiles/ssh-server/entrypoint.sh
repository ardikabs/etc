#!/bin/bash

set -eu

set_custom_user() {
    local username
    local password

    if [ -n "${SSH_USERNAME:-}" ]; then
        username=${SSH_USERNAME}
        password=${SSH_PASSWORD:-!1Password}

        useradd -rm -d /home/"${username}" -s /bin/bash -g root -G sudo -u 1001 "${username}"
        echo "${username}:${password}" | chpasswd
    fi
}

set_sshd_config() {
    if [ -n "${SSH_PORT:-}" ] && [ "${SSH_PORT}" -eq "${SSH_PORT}" ]  2>/dev/null; then
        sed -i -e "s/#Port 22/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
    fi
}

set_authorized_keys() {
    # Single ssh public key
    if [ -n "${SSH_PUBLIC_KEY:-}" ]; then
        echo -n "${SSH_PUBLIC_KEY}" >> ~/.ssh/authorized_keys
    fi

    # Multiple ssh public keys separating by commas
    if [ -n "${SSH_PUBLIC_KEYS:-}" ]; then
        echo -n "${SSH_PUBLIC_KEYS}" | tr ',' '\n' >> ~/.ssh/authorized_keys
    fi
}


set_authorized_keys
set_custom_user
set_sshd_config

set -- /usr/sbin/sshd -D
exec "$@"