# Running Qualcomm Launcher on Manjaro

## First!
Download the file from the Qualcomm page for the Rubik Pi3. `qualcommlauncher2.0.0.Linux-x86.deb`.

-------

This directory contains a local extraction of `qualcommlauncher2.0.0.Linux-x86.deb`.

Run it with:

```sh
./run-qualcommlauncher.sh
```

The Debian package wants these runtime libraries: `bash`, `gtk3`, `libnotify`,
`nss`, `libxss`, `libxtst`, `xdg-utils`, `at-spi2-core`, `util-linux-libs`,
`libsecret`, `libusb`, and `libarchive`. They were already installed on this
Manjaro system when checked.

The wrapper passes `--no-sandbox` because the Chromium/Electron sandbox helper
from the Debian package is not installed system-wide with root ownership and the
setuid bit.

The bundled Qualcomm `qdl` flashing helper needs the older `libxml2.so.2` ABI.
On this system the compatibility library is vendored locally from Manjaro's
`libxml2-legacy` package under `compat-libs/`, and the wrapper adds it to
`LD_LIBRARY_PATH`.

## USB device access

If the app opens but cannot see or flash a board, check the device permissions:

```sh
lsusb
ls -l /dev/bus/usb/*/*
```

For one-off testing, start the launcher with elevated privileges:

```sh
sudo ./run-qualcommlauncher.sh
```

For regular use, create a udev rule for the board vendor/product IDs shown by
`lsusb`, reload udev, then unplug and reconnect the board.

For Qualcomm QDL mode on the Rubik Pi, this helper installs the rule:

```sh
sudo ./install-qdl-udev-rule.sh
```

Then unplug and reconnect the board and run:

```sh
./run-qualcommlauncher.sh
```
