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

## update the system and get rid of old crap (retained packages..)
("dist-upgrade" instead of "upgrade" also resolves dependencies; if this is not wanted, then just use "upgrade")
```sudo apt-get update && sudo apt-get dist-upgrade && sudo apt-get autoremove && sudo apt-get autoclean```

## SSH: edit files if there is no vi, nano, ..
'cat' first the file, then copy&paste to some editor on the host system, the pipe it into the old file via
```cat > fileToEdit.conf``` && copy&paste && escape via CTRL+C.

## search and re-run a command
"Type <Ctrl+R> at the command line and start typing the previous command. Once a result appears keep hitting <Ctrl+R> to see other matches. When the command you want appears, simply press <Enter>"
  
## find out current distribution version
```lsb_release -a```

## check details (like: which Kubuntu version)
```kinfocenter```

## apply mp3gain recursively (89 dB)
```find ./ -type d -exec bash -c 'cd "$1"; mp3gain -a -k -m 3 *.mp3' -- {} \;```

## check where a symlink leads to
```
$ readlink -f /usr/bin/ld
/usr/bin/x86_64-linux-gnu-ld.bfd
```
  
## connmanctl for tethering
```
connmanctl tether wifi on Bananen brotbrot
Wifi SSID set
Wifi passphrase set
Enabled tethering for wifi
```

## find all files of certain type which DON't contain certain string
example: "copyright" for the license in qml-files:
```
$ grep -inr --include \*.qml -L "Copyright" .
```
## check which systemd services are configured (and enabled)
```
systemctl list-unit-files | grep enabled will list all enabled ones
```

# sound mixer
$ alsamixer
