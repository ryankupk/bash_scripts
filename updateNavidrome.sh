#!/usr/bin/bash

if [ "$EUID" -ne 0 ]
        then echo "must run as root"
        exit
fi

while getopts u: flag
do
        case "$flag" in
                u) release_url=${OPTARG};;
        esac
done

zip_filename="${release_url##*/}"
cd /opt/navidrome/ || exit 1
wget "$release_url" --output-document "$zip_filename"
systemctl stop navidrome.service
rm navidrome
tar -xzf "$zip_filename"
systemctl reload-or-restart navidrome.service
rm "$zip_filename"
