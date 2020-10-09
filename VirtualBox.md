# Cheat sheet for Virtual Box (Oracle)

## handling

* HOST key is by default: right CTRL
* HOST + C: scaled version of the desktop
* HOST + F: fullscreen

## graphics / display

* for Linux guest VMSVGA is recommended (newer implementation); for Windows guest VBoxSVGA
* install VirtualBox-extensions and then while in fullscreen at the lower bottom the menu appears to set additional monitors (did not work or change something!) or press HOST + Pos1 (Home)

## challenge: 2 assigned displays (in VirtualBox) are not recognized inside the VM (Kubuntu):
* let the VB-Extensions mount the "extension CD"
* execute "$ ./autorun.sh"
* looks like previosly some outdated extensions were installed

> Verifying archive integrity... All good.  
> Uncompressing VirtualBox 6.1.14 Guest Additions for Linux........  
> VirtualBox Guest Additions installer  
> Removing installed version 6.1.2 of VirtualBox Guest Additions...  
> update-initramfs: Generating /boot/initrd.img-5.3.0-64-generic  
> [..]
