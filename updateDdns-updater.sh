#!/usr/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 -u <release_url>"
    echo "  -u: URL of the DDNS updater release to download"
    exit 1
}

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

# Parse command line arguments
while getopts "u:" flag; do
    case "${flag}" in
        u) release_url=${OPTARG};;
        *) usage;;
    esac
done

# Check if release_url is provided
if [ -z "$release_url" ]; then
    echo "Error: Release URL is required."
    usage
fi

echo "Updating ddns-updater"

# Change to the correct directory
cd /opt/ddns-updater/ || { echo "Error: Unable to change directory to /opt/ddns-updater/"; exit 1; }

# Stop the service
echo "Stopping ddns-updater service..."
systemctl stop ddns-updater.service || { echo "Warning: Failed to stop ddns-updater service"; }

# Remove old version
echo "Removing old version..."
rm -f ddns_updater

# Download new version
echo "Downloading new version..."
if wget --output-document ddns_updater "$release_url"; then
    echo "Download successful."
else
    echo "Error: Failed to download new version"
    exit 1
fi

# Set executable permissions
echo "Setting executable permissions..."
chmod +x ddns_updater || { echo "Error: Failed to set executable permissions"; exit 1; }

# Restart the service
echo "Restarting ddns-updater service..."
if systemctl reload-or-restart ddns-updater.service; then
    echo "DDNS Updater successfully updated and restarted"
else
    echo "Error: Failed to restart ddns-updater service"
    exit 1
fi
