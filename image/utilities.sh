#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

## Often used tools.
$minimal_apk_install curl less vim psmisc gnupg

## This tool runs a command as another user and sets $HOME.
cp /bd_build/bin/setuser /sbin/setuser

## This tool allows installation of apk packages with automatic cache cleanup.
cp /bd_build/bin/install_clean /sbin/install_clean