#!/bin/bash

# Ensure ffmpeg and mp3gain are installed
command -v ffmpeg >/dev/null 2>&1 || { echo "ffmpeg is required but not installed. Exiting."; exit 1; }
command -v mp3gain >/dev/null 2>&1 || { echo "mp3gain is required but not installed. Exiting."; exit 1; }

# Loop through all non-MP3 files in the current directory
for file in *; do
    # Skip directories and MP3 files
    if [[ -d "$file" || "${file##*.}" == "mp3" ]]; then
        continue
    fi

    # Define the output MP3 filename
    output="${file%.*}.mp3"

    echo "Processing '$file' -> '$output'"

    # Convert the file to MP3 with quality 0 and preserve metadata
    ffmpeg -i "$file" -q:a 0 -map_metadata 0 "$output"

    # Normalize loudness to 89 dB using replaygain
    ffmpeg -i "$output" -af "replaygain" "normalized_$output"
    mv "normalized_$output" "$output"

    # Optionally split the MP3 into 10-minute chunks (comment out if not needed)
    ffmpeg -i "$output" -f segment -segment_time 600 -c copy "${output%.*}_%03d.mp3"

    # Clean up the original MP3 if splitting is done
    if [[ -e "${output%.*}_000.mp3" ]]; then
        rm "$output"
    fi
done

echo "Conversion and normalization completed!"
