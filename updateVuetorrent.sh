#!/bin/bash

# don't allow script execution if not executing as sudo
if [ "$EUID" -ne 0 ]
        then echo "must run as root"
        exit
fi

echo "Upating vuetorrent"

cd /opt/VueTorrent
git fetch && git pull
