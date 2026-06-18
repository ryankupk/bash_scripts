#!/usr/bin/fish

if test (id -u) -ne 0
    echo "must run as root"
    exit 1
end

# Load shared helpers (banner output)
source (dirname (realpath (status filename)))/banner.fish

set download_url "https://github.com/9001/copyparty/releases/latest/download/copyparty-sfx.py"
set install_path /usr/local/bin/copyparty-sfx.py

# Look up the latest released version
set latest_version (curl -s https://api.github.com/repos/9001/copyparty/releases/latest \
    | string match -rg '"tag_name":\s*"v?([^"]+)"')

if test -z "$latest_version"
    echo "could not determine the latest copyparty version"
    exit 1
end

# Compare against the installed version and skip if already current
set current_version ""
if test -f "$install_path"
    set current_version (python3 "$install_path" --version 2>&1 | string match -rg 'copyparty\s+v?(\d+\.\d+\.\d+)' | head -1)
end

if test "$current_version" = "$latest_version"
    print_banner "Copyparty: already up to date ($current_version)"
    exit 0
end

if test -n "$current_version"
    print_banner "Updating Copyparty: $current_version -> $latest_version"
else
    print_banner "Updating Copyparty: unknown -> $latest_version"
end

wget "$download_url" --output-document "$install_path"; or begin
    echo "Error: failed to download copyparty"
    exit 1
end
chmod 644 "$install_path"
systemctl reload-or-restart copyparty.service
set version (python3 "$install_path" --version 2>&1 | string match -rg '(copyparty \S+)' | head -1)
echo "Done. Version: $version"
