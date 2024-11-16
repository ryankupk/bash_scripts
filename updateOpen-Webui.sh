#!/bin/bash

# Set strict mode
set -euo pipefail

# Configuration
APP_DIR="/opt/open-webui"

# Function to display error messages and exit
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    error_exit "This script must be run as root or with sudo privileges."
fi

# Change to the application directory
echo "Changing to application directory: $APP_DIR"
cd "$APP_DIR" || error_exit "Failed to change to directory: $APP_DIR"

# Pull latest images
echo "Pulling latest Docker images..."
if docker compose pull; then
    echo "Successfully pulled latest images."
else
    error_exit "Failed to pull latest Docker images."
fi

# Update and restart containers
echo "Updating and restarting containers..."
if docker compose up -d; then
    echo "Successfully updated and restarted containers."
else
    error_exit "Failed to update and restart containers."
fi

echo "Docker Compose application update completed successfully."
