#!/bin/bash
#
# pullMyBackups.sh
# Bash script for unattended pulling of multiple remote backups
# Project URL: https://github.com/AlexGidarakos/pullMyBackups
#
# pullMyBackups.sh is designed to run with root privileges from a daily
# cronjob and pull multiple remote backups from multiple remote Linux servers.
# For each backup set, a configuration file with a .conf extension must be
# created inside the conf.d subdirectory. See conf.d/example.conf.README for
# an example.
# Dependencies: Bash, GNU coreutils, rsync, ssh, gzip. With some
# modifications, it should also work for other shells and/or systems.
# Tested on: Debian GNU/Linux 8.4 amd64
#
# Copyright 2016, Alexandros Gidarakos.
# Author: Alexandros Gidarakos <algida79@gmail.com>
# Author URL: http://linkedin.com/in/alexandrosgidarakos
#
# SPDX-License-Identifier: GPL-2.0

# Check for root priviliges
if [[ $(whoami) != "root" ]]; then
    echo "This script should only be run as root - Exiting..."
    exit 1
fi

# Store script's basedir
PMB_DIR=$(dirname $(realpath $0))

#Store script's log file path
PMB_LOG=$PMB_DIR/pullMyBackups.log

# Logging function
pmbLog () { echo $(date +%Y-%m-%d\ %H:%M:%S) - $1 >> $PMB_LOG; }

# This function starts a timer
pmbTimerStart () { PMB_TIME_1=$(date +%s); }

# This function stops the timer and stores result in $PMB_DURATION as seconds
pmbTimerStop () { PMB_TIME_2=$(date +%s); PMB_DURATION=$((PMB_TIME_2-PMB_TIME_1)); }

pmbLog "Invoked"

# Loop over configuration files
for PMB_CONF_FILE in $PMB_DIR/conf.d/*; do
    # Ignore files not ending with .conf
    if [[ ${PMB_CONF_FILE##*.} != "conf" ]]; then continue; fi

    # Clear configuration variables from previous loop iteration
    unset PMB_NAME
    unset PMB_SOURCE
    PMB_SOURCE_PORT=22
    unset PMB_TARGET

    # Load configuration variables from file
    pmbLog "Loading configuration file: $PMB_CONF_FILE"
    source $PMB_CONF_FILE

    # Check if minimum required configuration variables are declared
    if [[ -z $PMB_NAME ]] || [[ -z $PMB_SOURCE ]] || [[ -z $PMB_TARGET ]]; then
        pmbLog "Bad configuration, ignoring $PMB_CONF_FILE"
        continue
    fi

    pmbLog "Found remote backup set $PMB_NAME in $PMB_SOURCE"
    pmbLog "Pulling remote backup set..."
    pmbTimerStart

    # Create target directory if it doesn't exist
    mkdir -p $PMB_TARGET

    # Pull remote backup set
    rsync -avz -e "ssh -p $PMB_SOURCE_PORT" --delete --progress $PMB_SOURCE/ $PMB_TARGET
    pmbTimerStop
    pmbLog "Remote backup set $PMB_NAME pulled in $PMB_DURATION seconds"
# Done with this backup set
done

# Log an exit message
pmbLog "Done"
