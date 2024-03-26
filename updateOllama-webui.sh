#!/bin/bash

# Stop the ollama-webui service
sudo systemctl stop ollama-webui.service

# Run the following as ollama-webui user in a bash shell
sudo -u ollama-webui bash -c '
# Source nvm
source /home/ollama-webui/init-nvm.sh

# Navigate to the git repository directory
cd /home/ollama-webui/ollama-webui

# Pull the latest changes from the repository, discarding any local changes
git fetch --all
git reset --hard origin/main

cd backend
pip3 install -r requirements.txt -U --quiet
cd ..

# Build the front-end
pnpm install
pnpm run build

# Change the port number in backend/start.sh from 8080 to 5173
sed -i "s/8080/5173/g" backend/start.sh
'

# Restart the ollama-webui service
sudo systemctl start ollama-webui.service
