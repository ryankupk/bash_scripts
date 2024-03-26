#!/bin/bash

usage() {
    echo "Usage: $0 -n prefix"
    exit 1
}

if [ "$#" -ne 2 ]; then
    usage
fi

while getopts ":n:" opt; do
  case $opt in
    n) prefix="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
       usage
    ;;
  esac
done

# Check if prefix is provided
if [ -z "$prefix" ]; then
    usage
fi

image_counter=1
video_counter=1

# Rename images
for file in *.{jpg,jpeg}; do
  if [ -f "$file" ]; then
    mv "$file" "${prefix}_image ${image_counter}.${file##*.}"
    ((image_counter++))
  fi
done

# Rename videos
for file in *.{mp4,m4a}; do
  if [ -f "$file" ]; then
    mv "$file" "${prefix}_video ${video_counter}.${file##*.}"
    ((video_counter++))
  fi
done

