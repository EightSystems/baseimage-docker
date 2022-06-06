#!/bin/bash

set -e

if [[ ! -e /etc/service/sshd/down && ! -e /etc/ssh/ssh_host_rsa_key ]] || [[ "$1" == "-f" ]]; then
    . /etc/init.d/sshd

    rm -f /etc/ssh/ssh_host_*_key
    rm -f /etc/ssh/ssh_host_*_key.pub

    echo "No SSH host key available. Generating one..."
    generate_host_keys
fi
