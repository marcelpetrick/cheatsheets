# Cheat sheet for bash (should work with most other shells and unix-like toolbox)

## create tree-like folder-structure (if ther is no 'tree')
```
find . | sed -e "s/[^-][^\/]*\// |/g" -e "s/|\([^ ]\)/|-\1/"
```

## show current load (periodically; 1/sec)
```
while true; do cat /proc/loadavg; sleep 1; done
```

## sort a file in place
Useful for a proper listing for the mailmap for git -.-
```
sort -o .mailmap .mailmap
```

## find a file and suppress the error messages (like 'Permission denied ..')
```
$ find / -name libSpellChecker.so 2> /dev/null
/home/mp/Documents/p118/Qt/Tools/QtCreator/lib/qtcreator/plugins/libSpellChecker.so
/home/mp/Downloads/lib/qtcreator/plugins/libSpellChecker.so
```

## copy with file-progress)
```
rsync -ah --progress source destination
```

## ssh with cleartext password (but if paste does not work..)
```sshpass -p 'YourPassword' ssh user@host```

# fresh HMI (just fab image without app): nothing works

### find the usb media (not auto mounted!)
```$ dmesg | tail -f```
or
```$ fdisk -l```

### mount (auto did not work as param for FAT32, so say explicitly vfat!)
```$ mount -t vfat /dev/sda /run/media/usbsticky```

### rauc it
```$ rauc install /run/media/usbsticky/xyz.raucb```

### reboot
```$ shutdown -r now```

## binary file not executable? "No suche file or directory" - despite existing file and chmod +X ..
### check ELF information
```readelf -h binFile```

### install fitting 32 bit architecture
```sudo apt-get install libc6-i386```

## show (usb) block devices
```lsblk```
