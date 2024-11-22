# convert m4a to mp3 and retain metadata
```bash
ffmpeg -i input.m4a -q:a 0 -map_metadata output.mp3
```

# cut the mp3 into 10 min-pieces with enumeration (for sorting)
```bash
ffmpeg -i input.mp3 -f segment -segment_time 600 -c copy output_%03d.mp3how to equalize to 89 db? gain adjustment?
```

# adjust loudness to 89 dB
```bash
ffmpeg -i input.mp3 -af "replaygain" output.mp3
```
