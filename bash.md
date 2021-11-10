# Cheat sheet for bash (should work with most other shells and unix-like toolbox)

general hints: [in german](http://kirste.userpage.fu-berlin.de/chemnet/general/topics/scripts_sh.html)

## create tree-like folder-structure (if ther is no 'tree')
```
find . | sed -e "s/[^-][^\/]*\// |/g" -e "s/|\([^ ]\)/|-\1/"
```

## show current load (periodically; 1/sec)
```
while true; do cat /proc/loadavg; sleep 1; done
```

## Log temperature into file and show it ..
```
while true; do cat /sys/class/thermal/thermal_zone0/temp | tee -a tempLogging20211011.txt; sleep 10; done
```

## Show currently used frequency (imx8m at least)
```
cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq 
1800000
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
```
sshpass -p 'YourPassword' ssh user@host
```

# fresh HMI (just fab image without app): nothing works

### find the usb media (not auto mounted!)
```
$ dmesg | tail -f
```
or
```
$ fdisk -l
```

### mount (auto did not work as param for FAT32, so say explicitly vfat!)
```
$ mount -t vfat /dev/sda /run/media/usbsticky
```

### rauc it
```
$ rauc install /run/media/usbsticky/xyz.raucb
rauc install /run/media/system/FAT32/p118-debug-bundle-imx8mm-p118.raucb
```

### reboot
```
$ shutdown -r now
```

## binary file not executable? "No such file or directory" - despite existing file and chmod +X ..
### check ELF information
```readelf -h binFile```

### install fitting 32 bit architecture
```sudo apt-get install libc6-i386```

## show (usb) block devices
```lsblk```

## update the system and get rid of old crap (retained packages..)
("dist-upgrade" instead of "upgrade" also resolves dependencies; if this is not wanted, then just use "upgrade")
```
sudo apt-get update --fix-missing && sudo apt-get dist-upgrade && sudo apt-get autoremove && sudo apt-get autoclean
```

## SSH: edit files if there is no vi, nano, ..
'cat' first the file, then copy&paste to some editor on the host system, the pipe it into the old file via
```cat > fileToEdit.conf``` && copy&paste && escape via CTRL+C.

## search and re-run a command
"Type <Ctrl+R> at the command line and start typing the previous command. Once a result appears keep hitting <Ctrl+R> to see other matches. When the command you want appears, simply press <Enter>"
  
## find out current distribution version
```
lsb_release -a
```

## check details (like: which Kubuntu version)
```
kinfocenter
```

## apply mp3gain recursively (89 dB)
```
find ./ -type d -exec bash -c 'cd "$1"; mp3gain -a -k -m 3 *.mp3' -- {} \;
```

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
  
## connman shortlist
```
connmanctl services
connmanctl scan wifi
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

## sound mixer in ascii-format
$ alsamixer

## problem that after booting the second display isn't used in the VM despite being recognized as "available" 
```
#!/bin/sh
# init the second desktop of the VM and assign some resolution (will be adjusted anyway ..)
xrandr --output Virtual2 --mode "1920x1440"
```

## edit the hostname (and displayed bluetooth name from connman)
```
cat > /etc/hostname
```
Note: only letters and a dash allowed, no underscore, no space! It would be written to file, but after reboot shown without them.
  
## show used size of certain (or current) directory 
```
du -hs .
```

## full backup of the NAS
* sorted after priorities; removed the compression because DS213 has just one core!
```
rsync -avrh /volume1/Photoshare_privat/ /volumeUSB1/usbshare/Photoshare_privat/ && \
rsync -avrh /volume1/homes/Marcel/ /volumeUSB1/usbshare/homes/Marcel/ && \
rsync -avrh /volume1/homes/ruzica/ /volumeUSB1/usbshare/homes/ruzica/ && \
rsync -avrh /volume1/homes/admin/ /volumeUSB1/usbshare/homes/admin/ && \
rsync -avrh /volume1/Camera/ /volumeUSB1/usbshare/Camera/ && \
rsync -avrh /volume1/photo/ /volumeUSB1/usbshare/photo/ && \
rsync -avrh /volume1/Musik/ /volumeUSB1/usbshare/Musik/
```

## Debugging on a remote system

### prepare proper core dumps

```
ulimit -c unlimited
echo 1 > /proc/sys/kernel/core_uses_pid
echo "/tmp/core-%e-%s-%u-%g-%p-%t" > /proc/sys/kernel/core_pattern
```

### if no coredumps exist, use gdb and get a backtrace
```
gdb <nameToApp> 
```
Then "set pagination off", "run" and then if there is a signal received, then "bt"

## clear the current line from all input
CTRL + U
  
## terminate process (for crashdump)
```
  kill -ABRT \'pidof PROCESS\' 
```

## backup the certificates
```
  marcelp@M-NB-267 MINGW64 /c/Repos/P118_HMI (mpe/textupdate)
$ scp root@192.168.0.42:/home/p118/p118/settings/Device_key.pem Device_key.pem
Device_key.pem                                                                                                                                            100% 3294   659.1KB/s   00:00

marcelp@M-NB-267 MINGW64 /c/Repos/P118_HMI (mpe/textupdate)
$ scp root@192.168.0.42:/home/p118/p118/settings/Device_cert.pem Device_cert.pem
Device_cert.pem                                                                                                                                           100% 2120   616.4KB/s   00:00
```

## the cheapest diskspace monitor (aka: looped df -h)
```
cmd="df -h"; for i in $(seq 1024); do $cmd; sleep 1; clear; done
```

## execute certain test out of a QTest-suite in loop and filter for the results
```
cmd="./AutomaticProgramTest test_nextInteractionUpdate"; for i in $(seq 10); do $cmd; done | grep failed
```

## Run python script in parallel on each cpp/qml-file inside a dir
```
( find . -name "*.qml" ; find . -name "*.h" ; find . -name "*.cpp" ) | parallel --bar python3 ~/Documents/pythonCollection/fixFileNameReferenceInsideHeader/fixFileNameReferenceInsideHeader.py
```

## Create file of certain size (here 2550 MiByte)
```
dd if=/dev/zero of=delme.file  bs=1M  count=2550
```

## Track currently used command (+x) and stop if something fails (+e)
```
set -ex
```

## List all symbolic links recursively for the current dir (symlink-issue with shared libs with qmake ..)
```
ls -lR . | grep ^l
```
  
## full load for four cores (xarg-version with md5sum does not work because of missing param -P)
```
fulload() { dd if=/dev/zero of=/dev/null | dd if=/dev/zero of=/dev/null | dd if=/dev/zero of=/dev/null | dd if=/dev/zero of=/dev/null & }; fulload; read; killall dd
```

# show lots of information about the used build  
```
cat /etc/build
```

# compress a set of files as tar.gz
```
tar -czvf logs.tar.gz *.log
```
