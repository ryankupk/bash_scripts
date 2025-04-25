#!/bin/bash

# Set strict mode
set -euo pipefail

# Configuration
APP_DIR="/opt/jellyseerr"

# Function to display error messages and exit
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    error_exit "This script must be run as root or with sudo privileges."
fi

echo "Updating jellyseerr"

# Change to the application directory
cd "$APP_DIR" || error_exit "Failed to change to directory: $APP_DIR"

sudo docker compose pull

sudo docker compose up -d

