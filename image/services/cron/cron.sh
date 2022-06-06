#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

mkdir -p /etc/service/cron
cp /bd_build/services/cron/cron.runit /etc/service/cron/run

ln -s /etc/crontabs/root /etc/crontab
ln -s /etc/periodic/15min /etc/cron.15min
ln -s /etc/periodic/hourly /etc/cron.hourly
ln -s /etc/periodic/daily /etc/cron.daily
ln -s /etc/periodic/weekly /etc/cron.weekly
ln -s /etc/periodic/monthly /etc/cron.monthly

chmod 600 /etc/crontab