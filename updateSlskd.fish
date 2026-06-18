#!/usr/bin/fish

set app_dir /opt/slskd

function error_exit
    echo "Error: $argv" >&2
    exit 1
end

# Check if running as root
if test (id -u) -ne 0
    error_exit "This script must be run as root or with sudo privileges."
end

# Load shared helpers (banner output)
source (dirname (realpath (status filename)))/banner.fish

print_banner "Updating slskd (docker compose)"

cd "$app_dir"; or error_exit "Failed to change to directory: $app_dir"

echo "Pulling latest Docker images..."
if docker compose pull
    echo "Successfully pulled latest images."
else
    error_exit "Failed to pull latest Docker images."
end

echo "Updating and restarting containers..."
if docker compose up -d
    echo "Successfully updated and restarted containers."
else
    error_exit "Failed to update and restart containers."
end

echo "Pruning dangling images..."
docker image prune -f

echo "Docker Compose application update completed successfully."
