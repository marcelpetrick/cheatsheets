# problem with snap updates after an update - was working before
```
error: system does not fully support snapd: cannot mount squashfs image using "squashfs":
       mount: /tmp/syscheck-mountpoint-4101993743: /dev/loop0 already mounted or mount point busy.

       dmesg(1) may have more information after failed mount system call.
```

## not the solution - reinstalling squashfs and snap
```
 sudo pacman -S squashfuse fuse2
 sudo pacman -Rns snapd
 sudo pacman -S snapd
 sudo systemctl enable --now snapd.socket
reboot
```
* people report that kernel 6.8 makes problem with snaps due to changes to the mountpoint
  * switching back to 6.6 LTS (20240419)


# virtual box
```
VirtualBox is not currently allowed to access USB devices. You can change this by adding your user to the 'vboxusers' group. Please see the user manual for a more detailed explanation.
```

* solution: `sudo usermod -aG vboxusers $(whoami)`
