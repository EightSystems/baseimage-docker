#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

find /bd_build/ -not \( -name 'bd_build' -or -name 'buildconfig' -or -name 'cleanup.sh' \) -delete
rm -rf /tmp/* /var/tmp/*

# clean up python bytecode
find / -name *.pyc -delete
find / -name *__pycache__* -delete

rm -f /etc/ssh/ssh_host_*