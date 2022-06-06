#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

SYSLOG_NG_BUILD_PATH=/bd_build/services/syslog-ng

## Install a syslog daemon.
$minimal_apk_install syslog-ng logrotate
cp $SYSLOG_NG_BUILD_PATH/syslog-ng.init /etc/my_init.d/10_syslog-ng.init
cp $SYSLOG_NG_BUILD_PATH/syslog-ng.shutdown /etc/my_init.post_shutdown.d/10_syslog-ng.shutdown
mkdir -p /var/lib/syslog-ng
cp $SYSLOG_NG_BUILD_PATH/syslog_ng_default /etc/default/syslog-ng
touch /var/log/syslog
chmod u=rw,g=r,o= /var/log/syslog
