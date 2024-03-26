#!/bin/bash

while getopts d: flag
do
	case "$flag" in 
		d) TARGET_DIR=${OPTARG};;
	esac
done

cd "$TARGET_DIR" || exit

find . -maxdepth 1 -type d | while read -r dir; do
    # Remove the leading './'
    dir="${dir:2}"

    # Check if the directory name contains a hyphen
    if [[ "$dir" == *"-"* ]]; then
        # Split the directory name into two parts by the hyphen
        part1="${dir%%-*}"
        part2="${dir#*-}"
        
        # Remove leading and trailing whitespaces
        part1="$(echo -e "${part1}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        part2="$(echo -e "${part2}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

        # If a directory with the first part as its name does not exist, create it
        if [ ! -d "$part1" ]; then
            mkdir "$part1"
        fi
        
        # Within the first part directory, create a directory with the second part as its name, if it doesn't exist
        if [ ! -d "$part1/$part2" ]; then
            mkdir "$part1/$part2"
        fi

        # Move all files from the original directory to the new directory (second part)
        find "$dir" -type f -exec mv {} "$part1/$part2" \;
        
        # Remove the original directory
        rmdir "$dir"
    fi
done

