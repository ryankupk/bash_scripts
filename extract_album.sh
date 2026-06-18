#!/bin/bash

set -e

# Initialize mktorrent_flag with a default value
mktorrent_flag=false

usage() {
  echo "Usage: $0 -a <artist> -t <title> -y <year> -d <download_path> -p <base_path> -z <zip_path> [-m <true|false>]"
  exit 1
}

while getopts ":a:t:d:p:y:z:m:" opt; do
  case $opt in
    a) artist="$OPTARG" ;;
    t) title="$OPTARG" ;;
    y) year="$OPTARG" ;;
    d) download_path="${OPTARG%/}" ;;
    p) base_path="${OPTARG%/}" ;;
    z) zip_path="$OPTARG" ;;
    m) mktorrent_flag="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2; usage ;;
  esac
done

# Check if all required arguments are provided
if [ -z "$artist" ] || [ -z "$title" ] || [ -z "$download_path" ] || [ -z "$base_path" ] || [ -z "$year" ] || [ -z "$zip_path" ]; then
  echo "Missing required arguments"
  usage
fi

# Create artist and title directories if they do not exist
artist_dir="$base_path/$artist"
title_dir="$artist_dir/$title"
final_dir="$download_path/$artist - $title ($year) [FLAC]"

mkdir -p "$artist_dir"
mkdir -p "$title_dir"
mkdir -p "$final_dir"

# Unzip the file
temp_dir=$(mktemp -d)
unzip "$zip_path" -d "$temp_dir"
deepest_dir=$(find "$temp_dir" -type d | sort -r | head -n 1)
mv "$deepest_dir"/* "$final_dir/"
rm -rf "$temp_dir"

# Optionally remove the zip file
echo "Removing zip file"
if [ -f "$zip_path" ]; then
    if rm "$zip_path" 2>/dev/null; then
        echo "Successfully removed zip file: $zip_path"
    else
        echo "Warning: Could not remove zip file: $zip_path (file may be in use or permission denied)"
    fi
else
    echo "Warning: Zip file not found: $zip_path"
fi

# Create torrent from the final directory
if [ "$mktorrent_flag" = true ]; then
    sudo mktorrent --source=OPS --private --announce=https://home.opsfet.ch/kEgjraqgpyuwjpvmhvawaejhnoffxDmn/announce -o "/home/ryankupk/${artist} - ${title} (${year}) [FLAC].torrent" "$final_dir"
fi

# Hardlink files into the artist/album directory in the base path
sudo ln "$final_dir"/* "$title_dir/"

