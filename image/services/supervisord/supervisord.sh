#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

if [ -f /usr/bin/supervisord ]; then
    mkdir -p /etc/service/supervisord
    cp /bd_build/services/supervisord/supervisord.runit /etc/service/supervisord/run
fi
