#!/bin/bash

# don't allow script execution if not executing as sudo
if [ "$EUID" -ne 0 ]
        then echo "must run as root"
        exit
fi

while getopts s:u:p: flag
do
        case "$flag" in
                s) new_subdomain=${OPTARG};;
        esac
done


echo "adding $new_subdomain to ddns-updater config"
sed -i "s/\(\"host\":\s*\".*\)\"/\1,$new_subdomain\"/" /opt/ddns-updater/data/config.json
