#!/usr/bin/fish

if test (id -u) -ne 0
    echo "must run as root"
    exit 1
end

# Load shared helpers (banner output)
source (dirname (realpath (status filename)))/banner.fish

print_banner "Updating VueTorrent (git pull)"

cd /opt/VueTorrent; or exit 1
git fetch; and git pull
