#!/usr/bin/fish

set app_dir /opt/homarr_mig

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

print_banner "Updating Homarr (docker compose)"

cd "$app_dir"; or error_exit "Failed to change to directory: $app_dir"

docker compose pull; or error_exit "Failed to pull latest images."
docker compose up -d; or error_exit "Failed to start containers."

echo "Pruning dangling images..."
docker image prune -f
