#!/usr/bin/fish

# Check if script is run as root
if test (id -u) -ne 0
    echo "Error: This script must be run as root"
    exit 1
end

# Load shared helpers (banner output)
source (dirname (realpath (status filename)))/banner.fish

# This host is amd64; the release asset name is fixed accordingly
set goarch amd64

# Fetch the latest release metadata once
set release_json (curl -s https://api.github.com/repos/qdm12/ddns-updater/releases/latest)
set latest_version (string match -rg '"tag_name":\s*"v?([^"]+)"' -- $release_json)
set all_urls (string match -rg '"browser_download_url":\s*"([^"]+)"' -- $release_json)
set release_url (string match -e "linux_$goarch" -- $all_urls)

if test -z "$latest_version"; or test -z "$release_url"
    echo "Error: could not determine the latest linux_$goarch release"
    exit 1
end

# Compare against the installed version and skip if already current
set current_version ""
if test -x /opt/ddns-updater/ddns_updater
    set current_version (/opt/ddns-updater/ddns_updater --version 2>/dev/null | string match -rg '(\d+\.\d+\.\d+)' | head -1)
end

if test "$current_version" = "$latest_version"
    print_banner "ddns-updater: already up to date ($current_version)"
    exit 0
end

if test -n "$current_version"
    print_banner "Updating ddns-updater: $current_version -> $latest_version"
else
    print_banner "Updating ddns-updater: unknown -> $latest_version"
end

# Change to the correct directory
cd /opt/ddns-updater/; or begin
    echo "Error: Unable to change directory to /opt/ddns-updater/"
    exit 1
end

# Stop the service
echo "Stopping ddns-updater service..."
systemctl stop ddns-updater.service; or echo "Warning: Failed to stop ddns-updater service"

# Remove old version
echo "Removing old version..."
rm -f ddns_updater

# Download new version
echo "Downloading new version..."
if wget --output-document ddns_updater "$release_url"
    echo "Download successful."
else
    echo "Error: Failed to download new version"
    exit 1
end

# Set executable permissions
echo "Setting executable permissions..."
chmod +x ddns_updater; or begin
    echo "Error: Failed to set executable permissions"
    exit 1
end

# Restart the service
echo "Restarting ddns-updater service..."
if systemctl reload-or-restart ddns-updater.service
    echo "DDNS Updater successfully updated and restarted"
else
    echo "Error: Failed to restart ddns-updater service"
    exit 1
end
