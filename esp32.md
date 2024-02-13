# Hints for the Espressif ESP32

## Get info which device was attached
```
lsusb > lsusb_before.txt
echo "attach device now .."
lsusb > lsusb_after.txt
diff lsusb_before.txt lsusb_after.txt

> Bus 001 Device 011: ID 303a:1001 Espressif USB JTAG/serial debug unit
```

```
 sudo dmesg | tail

[ 5185.337263] usb 1-2: USB disconnect, device number 12
[ 5192.855872] usb 1-2: new full-speed USB device number 14 using xhci_hcd
[ 5192.997065] usb 1-2: New USB device found, idVendor=303a, idProduct=1001, bcdDevice= 1.02
[ 5192.997079] usb 1-2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[ 5192.997084] usb 1-2: Product: USB JTAG/serial debug unit
[ 5192.997087] usb 1-2: Manufacturer: Espressif
[ 5192.997091] usb 1-2: SerialNumber: 40:4C:CA:51:45:44
[ 5193.000248] cdc_acm 1-2:1.0: ttyACM0: USB ACM device
```

### terminal multiplexer
`sudo screen-4.9.1 /dev/ttyACM0 115200`

`sudo minicom -s`
* exit with CTRL+A, then X

* source the path
`. ./export.sh`

## problem: cmake - somehow confused with cmake from python?!?
```
    ~/repos/esp/esp-idf    master !8  . ./export.sh                                                                                                                                                                          127 ✘ 
Setting IDF_PATH to '/home/mpetrick/repos/esp/esp-idf'
Detecting the Python interpreter
Checking "python3" ...
Python 3.11.6
"python3" has been detected
Checking Python compatibility
Checking other ESP-IDF version.
ERROR: tool cmake found in path, but returned non-zero exit code (1) with error message:
Traceback (most recent call last):
  File "/home/mpetrick/.local/bin/cmake", line 5, in <module>
    from cmake import cmake
ModuleNotFoundError: No module named 'cmake'

    ~/repos/esp/esp-idf    master !8  cmake --version                                                                                                                                                                          1 ✘ 
Traceback (most recent call last):
  File "/home/mpetrick/.local/bin/cmake", line 5, in <module>
    from cmake import cmake
ModuleNotFoundError: No module named 'cmake'
    ~/repos/esp/esp-idf    master !8    
```
fixed by renaming (instead of just deleting) the file: still not sure where this comes from
`` mv /home/mpetrick/.local/bin/cmake /home/mpetrick/.local/bin/cmake1  

## fix problems with `idf.py flash`
* add user to group (for Manjaro Linux)
`sudo usermod -a -G uucp $USER `
* make the device writeable
` sudo chmod a+rw /dev/ttyACM0`
