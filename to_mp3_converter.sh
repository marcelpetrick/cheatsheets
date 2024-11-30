#!/bin/bash

# Script to process and convert audio/video files to MP3 with normalized loudness
# Usage: ./script.sh <input_directory>

# Check if a parameter is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <input_directory>"
    exit 1
fi

# Set the input directory
INPUT_DIR="$1"

# Check if the input directory exists
if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Error: Directory '$INPUT_DIR' does not exist."
    exit 1
fi

# Change to the input directory
cd "$INPUT_DIR" || { echo "Error: Failed to navigate to '$INPUT_DIR'."; exit 1; }

# Fix naming for all files (replace ? characters with _)
for file in *\?*; do
    mv -- "$file" "${file//\?/_}"
done

# Ensure ffmpeg and mp3gain are installed
command -v ffmpeg >/dev/null 2>&1 || { echo "ffmpeg is required but not installed. Exiting."; exit 1; }
command -v mp3gain >/dev/null 2>&1 || { echo "mp3gain is required but not installed. Exiting."; exit 1; }

# Loop through all supported input files in the directory
for file in *.{mp4,opus,ogg,wav,flac,m4a}; do
    # Skip if no files are found
    [[ -e "$file" ]] || continue

    # Skip directories
    if [[ -d "$file" ]]; then
        continue
    fi

    # Define the output MP3 filename
    output="${file%.*}.mp3"

    echo "Processing '$file' -> '$output'"

    # Convert the file to MP3 with quality 0 and preserve metadata
    ffmpeg -i "$file" -q:a 0 -map_metadata 0 "$output" -y

    # Normalize loudness to 89 dB using replaygain
    ffmpeg -i "$output" -af "replaygain" "normalized_$output" -y
    mv "normalized_$output" "$output"

    # Optionally split the MP3 into 10-minute chunks (comment out if not needed)
    # Uncomment the following lines if you want to enable splitting
    # ffmpeg -i "$output" -f segment -segment_time 600 -c copy "${output%.*}_%03d.mp3"

    # Uncomment if splitting and want to remove the original MP3 after splitting
    # if [[ -e "${output%.*}_000.mp3" ]]; then
    #     rm "$output"
    # fi
done

echo "Conversion and normalization completed in '$INPUT_DIR'!"
