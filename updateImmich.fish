#!/usr/bin/fish

set app_dir /opt/immich

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

# Latest published Immich version (for the banner; the images track :release)
set latest_version (curl -s https://api.github.com/repos/immich-app/immich/releases/latest | string match -rg '"tag_name":\s*"([^"]+)"')

if test -n "$latest_version"
    print_banner "Updating Immich (docker compose) -> $latest_version"
else
    print_banner "Updating Immich (docker compose)"
end

cd "$app_dir"; or error_exit "Failed to change to directory: $app_dir"

# Immich pins its database/redis images in the compose file itself and bumps
# them between releases, sometimes with breaking migrations (e.g. pgvecto-rs ->
# VectorChord). `docker compose pull` cannot see those changes, so compare our
# pinned images against the latest published compose and stop if they drift,
# rather than pulling a newer app onto an incompatible database.
set latest_compose (mktemp)
if curl -fsSL "https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml" -o $latest_compose
    set img_diff (diff \
        (grep -E '^\s*image:' docker-compose.yml | string trim | sort | psub) \
        (grep -E '^\s*image:' $latest_compose | string trim | sort | psub) \
        | grep -E '^[<>]')
    rm -f $latest_compose
    if test (count $img_diff) -gt 0
        echo
        print_banner "Immich: pinned images differ from the latest release — update held"
        echo "  '<' = your docker-compose.yml      '>' = latest release ($latest_version)"
        printf '  %s\n' $img_diff
        echo
        echo "  These changes are NOT applied automatically: some (e.g. the"
        echo "  pgvecto-rs -> VectorChord database switch) require manual migration."
        echo "  Pulling a newer app onto an unmigrated database can break startup."
        echo "  Review the release notes, update docker-compose.yml accordingly, then"
        echo "  re-run this script:"
        echo "    https://github.com/immich-app/immich/releases"
        exit 1
    end
    echo "Pinned database/redis images already match the latest release."
else
    rm -f $latest_compose
    echo "Warning: could not fetch the latest Immich compose for comparison; continuing."
end

# Pull and (re)start the application images (these track the :release tag)
docker compose pull; or error_exit "Failed to pull latest images."
docker compose up -d; or error_exit "Failed to start containers."

echo "Pruning dangling images..."
docker image prune -f
