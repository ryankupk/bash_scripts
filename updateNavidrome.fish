#!/usr/bin/fish

if test (id -u) -ne 0
    echo "must run as root"
    exit 1
end

# Load shared helpers (banner output)
source (dirname (realpath (status filename)))/banner.fish

# This host is amd64; the release asset name is fixed accordingly
set goarch amd64

# Fetch the latest release metadata once
set release_json (curl -s https://api.github.com/repos/navidrome/navidrome/releases/latest)
set latest_version (string match -rg '"tag_name":\s*"v?([^"]+)"' -- $release_json)
set all_urls (string match -rg '"browser_download_url":\s*"([^"]+)"' -- $release_json)
set release_url (string match -e "linux_$goarch.tar.gz" -- $all_urls)

if test -z "$latest_version"; or test -z "$release_url"
    echo "could not determine the latest linux_$goarch release"
    exit 1
end

# Compare against the installed version and skip if already current
set current_version ""
if test -x /opt/navidrome/navidrome
    set current_version (/opt/navidrome/navidrome --version 2>/dev/null | string match -rg '(\d+\.\d+\.\d+)' | head -1)
end

if test "$current_version" = "$latest_version"
    print_banner "Navidrome: already up to date ($current_version)"
    exit 0
end

if test -n "$current_version"
    print_banner "Updating Navidrome: $current_version -> $latest_version"
else
    print_banner "Updating Navidrome: unknown -> $latest_version"
end

# Download and install the new release
set zip_filename (basename $release_url)
cd /opt/navidrome/; or begin
    echo "Error: unable to change to /opt/navidrome/"
    exit 1
end

wget $release_url --output-document $zip_filename; or begin
    echo "Error: failed to download release"
    exit 1
end
echo "Downloaded release"

systemctl stop navidrome.service; or echo "Warning: failed to stop navidrome service"
echo "Stopped navidrome service"

rm navidrome
echo "Removed old binary"

tar -xzf $zip_filename; or begin
    echo "Error: failed to extract $zip_filename"
    exit 1
end
echo "Unzipped $zip_filename"

systemctl reload-or-restart navidrome.service
echo "Restarted navidrome service"

rm $zip_filename
echo "Removed zip file"
