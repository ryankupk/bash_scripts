#!/bin/bash

# don't allow script execution if not executing as sudo
if [ "$EUID" -ne 0 ]
        then echo "must run as root"
        exit
fi

systemctl stop ollama.service 
curl https://ollama.ai/install.sh | sh 
systemctl restart ollama.service
