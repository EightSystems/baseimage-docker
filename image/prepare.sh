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

for bin in sv runsvdir runsvchdir; do
    target="$(command -v "$bin" || true)"
    [ -n "$target" ] || { echo "runit binary not found: $bin" >&2; exit 1; }
    if [ "$target" != "/usr/bin/$bin" ]; then
        rm -f "/usr/bin/$bin"
        ln -s "$target" "/usr/bin/$bin"
    fi
done

echo -n en_US.UTF-8 > /etc/container_environment/LANG
echo -n en_US.UTF-8 > /etc/container_environment/LC_CTYPE