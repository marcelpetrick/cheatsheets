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

## copy (with file-progress)
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
("dist-upgrade" instead of "upgrade" also resolves dependencies; if this is not wanted, then just use "upgrade"; all auto-confirmed)
```
sudo apt-get update --fix-missing -y && sudo apt-get dist-upgrade -y && sudo apt-get autoremove -y && sudo apt-get autoclean -y
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
* sorted after priorities; removed the compression (z flag) because DS213 has just one core!
```
rsync -avrh /volume1/Photoshare_privat/ /volumeUSB1/usbshare/Photoshare_privat/ && \
rsync -avrh /volume1/homes/Marcel/ /volumeUSB1/usbshare/homes/Marcel/ && \
rsync -avrh /volume1/homes/ruzica/ /volumeUSB1/usbshare/homes/ruzica/ && \
rsync -avrh /volume1/homes/admin/ /volumeUSB1/usbshare/homes/admin/ && \
rsync -avrh /volume1/Camera/ /volumeUSB1/usbshare/Camera/ && \
rsync -avrh /volume1/photo/ /volumeUSB1/usbshare/photo/ && \
rsync -avrh /volume1/Musik/ /volumeUSB1/usbshare/Musik/
```
## current version via RPi400 as remote, sudo to avoid timesetting-error  
* avoid having to enter the password, stored in plaintext (cybersecurity ..) and passed via `sshpass`
```
sshpass -p $(cat /home/pi/rsync_pw) sudo rsync -avrh admin@ds213:/volume1/Photoshare_privat/ /media/pi/1.42.6-25556/Photoshare_privat/ && \
sshpass -p $(cat /home/pi/rsync_pw) sudo rsync -avrh admin@ds213:/volume1/homes/Marcel/ /media/pi/1.42.6-25556/homes/Marcel/ && \
sshpass -p $(cat /home/pi/rsync_pw) sudo rsync -avrh admin@ds213:/volume1/homes/ruzica/ /media/pi/1.42.6-25556/homes/ruzica/ && \
sshpass -p $(cat /home/pi/rsync_pw) sudo rsync -avrh admin@ds213:/volume1/homes/admin/ /media/pi/1.42.6-25556/homes/admin/ && \
sshpass -p $(cat /home/pi/rsync_pw) sudo rsync -avrh admin@ds213:/volume1/Camera/ /media/pi/1.42.6-25556/Camera/ && \
sshpass -p $(cat /home/pi/rsync_pw) sudo rsync -avrh admin@ds213:/volume1/photo/ /media/pi/1.42.6-25556/photo/ && \
sshpass -p $(cat /home/pi/rsync_pw) sudo rsync -avrh admin@ds213:/volume1/Musik/ /media/pi/1.42.6-25556/Musik/
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

## continuous loop for testing the download speed of a certain blob
* escaping & param with single quote for the URL!
```
while true; do curl -O 'https://foo.bar.com/foofoo.bar'; done
```
  
### touch controller update
```
md5sum /lib/firmware/ilitek/ili251x.bin
3cfa957fe8bc7fc695396946b0a1f106

echo 1 > /sys/devices/platform/soc@0/30800000.bus/30a30000.i2c/i2c-1/1-0041/firmware_update
cat /sys/devices/platform/soc@0/30800000.bus/30a30000.i2c/i2c-1/1-0041/{{firmware,kernel,protocol}_version,mode} 
```

# Fix the keyboard layout
* worked for Kubuntu 22.04, because I could not find any menu in that fancy KDE, which allows to changes that (wtf!)  
`sudo dpkg-reconfigure keyboard-configuration`
  
# weather-app for cheap
`while :; do clear; curl wttr.in/Laim; date; sleep 60; done`

# Manjaro
`full system info  inxi -Fxxxz`

# check all ts-files for unfinished translations
`grep -i -r --include=\*.ts "unfinished" .`

# `unpack` existing RAUC
```
      ~/Downloads/tamperp118  sudo unsquashfs -d extract tampered_p118-debug-bundle-imx8mm-p118-01.04.006.raucb                                     1 ✘ 
Parallel unsquashfs: Using 12 processors
4 inodes (9153 blocks) to write

[=========================================================================================================================================\] 9157/9157 100%

created 4 files
created 1 directory
created 0 symlinks
created 0 devices
created 0 fifos
created 0 sockets
created 0 hardlinks
    ~/Downloads/tamperp118     
```
  
  Don't use param -f with an existing directory.

# change a single byte randomly at the end of the file
`sudo dd if=/dev/urandom of=p118-debug-image-imx8mm-p118.tar bs=1 count=1 seek=$(($(stat -c%s "p118-debug-image-imx8mm-p118.tar") - 1)) conv=notrunc`

## configure ip manually for eth for accessing a special hmi
```
470  sudo ifconfig eno2 down\n
471  sudo ifconfig eno2 192.168.0.41\n
472  ifconfig
473  ping 192.168.0.42
```

## problem: `Unable to negotiate with 192.168.0.42 port 22: no matching host key type found. Their offer: ssh-rsa`
Either add it to the ssh-command, but then other tools fails, which offer no proper interface (like rsync called as part of a deployment step) ..
`ssh -oHostKeyAlgorithms=+ssh-rsa root@10.42.0.176` 
or
`sudo nano ~/.ssh/config` and then insert:
```
Host 192.168.0.42
    User ps
    PubkeyAcceptedAlgorithms +ssh-rsa
    HostkeyAlgorithms +ssh-rsa
```

## change remotely the access-rights for a certain folder
`ssh -oHostKeyAlgorithms=+ssh-rsa root@10.42.0.176 chown -R p118:p118 /opt/P118`

## manjaro linux - fix problem with slow mirrors
`sudo pacman-mirrors -f 5 && sudo pacman -Syyu`

## chrome complains it is outdated and pacman does not show any missing updates
* rebuild the packages from Microsoft (affects teams and VSCode)
`pamac update -a`

## number of available cpu cores - checked in different ways
```
echo "cpu check start ----------------------"
nproc
nproc --all
cat  /proc/cpuinfo
grep -c "^processor" /proc/cpuinfo
echo "cpu check end ----------------------"
```

## write image to sd-card
* check with `lsblk` first which device could be the one you want to write to
* takes care of writing and synching:
`sudo dd if=data-modul-image-qt6-data-modul-imx8mp-edm-sbc-20231111193730.rootfs.wic of=/dev/mmcblk0 bs=1M status=progress conv=fsync`

## compare the content of two zip-files
`diff <(unzip -l zipfile1.zip) <(unzip -l zipfile2.zip)`
note: if the contained files have different creation dats, this is a difference as well

# check if a port on a device is open/closed/filtered
Eitehr netcat (nc), nmap or traceroute (tracepath).
```
    ~  netcat -vz git.data-modul.com 5050                                                                                                                                                                                           ✔ 
git.data-modul.com [80.147.197.41] 5050 (mmcc) open
    ~  nmap -p 5050 git.data-modul.com                                                                                                                                                                                              ✔ 

Starting Nmap 7.94 ( https://nmap.org ) at 2024-01-10 11:27 CET
Nmap scan report for git.data-modul.com (80.147.197.41)
Host is up (0.021s latency).
rDNS record for 80.147.197.41: p5093c529.dip0.t-ipconnect.de

PORT     STATE SERVICE
5050/tcp open  mmcc

Nmap done: 1 IP address (1 host up) scanned in 0.10 seconds
    ~  tracepath git.data-modul.com                                                                                                                                                                                                 ✔ 

 1?: [LOCALHOST]                      pmtu 1500
 1:  172.16.28.1                                           2.673ms 
 1:  172.16.28.1                                           2.628ms 
 2:  172.16.28.1                                           2.528ms pmtu 1400
```
# zsh: more than the last 16 entries for history
`alias history="fc -l 1"`

# execute a certain QTest in a loop and just check the results
Remove the other output as well.  
`for i in {1..10}; do ./tst_azureiothub 2>&1 | grep "^Totals:"; done`  
For a more sophisticated shellscript which runs infinitely and breaks when an error happens, check [https://github.com/marcelpetrick/codingWithGPT/blob/master/runTestContinuously/runTestContinuously.sh](https://github.com/marcelpetrick/codingWithGPT/blob/master/runTestContinuously/runTestContinuously.sh)

# color the output of stderr and stdout in different ways
* first part is the fake-program which prints continuously, the part after `done`is the real deal
`while true; do echo "foo"; echo "bar" >&2; sleep 1; done 2> >(sed $'s,.*,\e[31m&\e[0m,') 1> >(sed $'s,.*,\e[32m&\e[0m,')`

## handle all snap updates
* `sudo snap refresh`
* `snap list` to see what is installed
* `snap warnings` for .. reviewing given warnings

## Manjaro Linux system update
* `sudo pacman -Syyu`
* check the results afterwards
```
    ~  lsb_release -a && uname -a                                                                                                                                                                                                   ✔ 
LSB Version:    n/a
Distributor ID: ManjaroLinux
Description:    Manjaro Linux
Release:        23.1.3
Codename:       Vulcan
Linux marcel-precision3551 6.7.0-0-MANJARO #1 SMP PREEMPT_DYNAMIC Mon Jan  8 02:04:09 UTC 2024 x86_64 GNU/Linux
    ~        
```

## convert all webp files to png
`for img in *.webp; do dwebp "$img" -o "${img%.webp}.png"; done` - install webp before: `libwebp`is the manjaro package

## kill a processes without any copy-paste of the PIDs
`ps -e | grep '[w]ine' | awk '{print $1}' | xargs kill  `

 ## manjaro - pacman - list all explicitely installed packages
 * Q for list; e for explicitely; d for dependencies
 ```
pacman -Qe | grep -i "qt"                                                                                                                                                                                                    ✔ 

packagekit-qt5 1.1.1-1
phonon-qt5-gstreamer 4.10.0-4
python-pyqt5 5.15.10-1
qt5-imageformats 5.15.12+kde+r10-1
qt5-virtualkeyboard 5.15.12-1
qt6-location 6.6.1-1
qt6-virtualkeyboard 6.6.1-1
qtcreator 12.0.1-2
```

## manjaro - update all flatpak packages
`sudo flatpak update`

## manjaro linux: one full update for all package-managers please
 ` sudo pacman -Syyu && echo "----------" && sudo flatpak update && echo "----------" && sudo snap refresh`
