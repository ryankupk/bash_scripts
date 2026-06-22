#!/usr/bin/fish

if test (id -u) -ne 0
    echo "must run as root"
    exit 1
end

# Load shared helpers (banner output)
source (dirname (realpath (status filename)))/banner.fish

# Fetch the latest release metadata once
set release_json (curl -s https://api.github.com/repos/ollama/ollama/releases/latest)
set latest_version (string match -rg '"tag_name":\s*"v?([^"]+)"' -- $release_json)

if test -z "$latest_version"
    echo "could not determine the latest Ollama release"
    exit 1
end

# Compare against the installed version and skip if already current
set current_version ""
if command -q ollama
    set current_version (ollama --version 2>/dev/null | string match -rg '(\d+\.\d+\.\d+)' | head -1)
end

if test "$current_version" = "$latest_version"
    print_banner "Ollama: already up to date ($current_version)"
    exit 0
end

if test -n "$current_version"
    print_banner "Updating Ollama: $current_version -> $latest_version"
else
    print_banner "Updating Ollama: unknown -> $latest_version"
end

curl -fsSL https://ollama.com/install.sh | sh
