#!/usr/bin/fish

if test (id -u) -ne 0
    echo "must run as root"
    exit 1
end

# Load shared helpers (banner output)
source (dirname (realpath (status filename)))/banner.fish

print_banner "Updating Ollama (install script)"

systemctl stop ollama.service
curl https://ollama.ai/install.sh | sh
systemctl restart ollama.service
