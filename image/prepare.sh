#!/bin/bash

set -e
source /bd_build/buildconfig
set -x

mkdir -p /etc/container_environment
mkdir -p /etc/default

## Enable Alpine Community Repositories
cat > /etc/apk/repositories << EOF; $(echo)

https://dl-cdn.alpinelinux.org/alpine/v$(cut -d'.' -f1,2 /etc/alpine-release)/main/
https://dl-cdn.alpinelinux.org/alpine/v$(cut -d'.' -f1,2 /etc/alpine-release)/community/
EOF

apk add --no-cache python3 runit

if [ ! -f /usr/bin/sv ]; then
    ln -s /sbin/sv /usr/bin/sv
fi

if [ ! -f /usr/bin/runsvdir ]; then
    ln -s /sbin/runsvdir /usr/bin/runsvdir
fi

if [ ! -f /usr/bin/runsvchdir ]; then
    ln -s /sbin/runsvchdir /usr/bin/runsvchdir
fi

echo -n en_US.UTF-8 > /etc/container_environment/LANG
echo -n en_US.UTF-8 > /etc/container_environment/LC_CTYPE