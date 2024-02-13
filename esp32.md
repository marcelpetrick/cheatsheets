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

* or use minicom
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
* add user to group (for Manjaro Linux) `sudo usermod -a -G uucp $USER `
* make the device writeable `sudo chmod a+rw /dev/ttyACM0`

### obviously by default the "wrong" chip is selected - ESP32 is not ESP32-C& (which I have)
```
"
    ~/repos/esp/esp-idf/examples/get-started/blink    master !8  idf.py flash                                                                                                                                            ✔  26s  
Executing action: flash
Serial port /dev/ttyACM0
Connecting...
Detecting chip type... ESP32-C6
Running ninja in directory /home/mpetrick/repos/esp/esp-idf/examples/get-started/blink/build
Executing "ninja flash"...
[1/5] cd /home/mpetrick/repos/esp/esp-idf/examples/get-started/blink/build/esp-idf/esptool_py && /home/mpetrick/.esp...uild/partition_table/partition-table.bin /home/mpetrick/repos/esp/esp-idf/examples/get-started/blink/build/blink.bin
blink.bin binary size 0x2d430 bytes. Smallest app partition is 0x100000 bytes. 0xd2bd0 bytes (82%) free.
[1/1] cd /home/mpetrick/repos/esp/esp-idf/examples/get-started/blink/build/bootloader/esp-idf/esptool_py && /home/mp...0x8000 bootloader 0x1000 /home/mpetrick/repos/esp/esp-idf/examples/get-started/blink/build/bootloader/bootloader.bin
Bootloader binary size 0x6870 bytes. 0x790 bytes (7%) free.
[4/5] cd /home/mpetrick/repos/esp/esp-idf/components/esptool_py && /usr/bin/cmake -D IDF_PATH=/home/mpetrick/repos/e...idf/examples/get-started/blink/build -P /home/mpetrick/repos/esp/esp-idf/components/esptool_py/run_serial_tool.cmake
esptool.py --chip esp32 -p /dev/ttyACM0 -b 460800 --before=default_reset --after=hard_reset write_flash --flash_mode dio --flash_freq 40m --flash_size 2MB 0x1000 bootloader/bootloader.bin 0x10000 blink.bin 0x8000 partition_table/partition-table.bin
esptool.py vv4.8.dev1
Serial port /dev/ttyACM0
Connecting...

A fatal error occurred: This chip is ESP32-C6 not ESP32. Wrong --chip argument?
CMake Error at run_serial_tool.cmake:66 (message):
  
  /home/mpetrick/.espressif/python_env/idf5.3_py3.11_env/bin/python;;/home/mpetrick/repos/esp/esp-idf/components/esptool_py/esptool/esptool.py;--chip;esp32
  failed.



FAILED: CMakeFiles/flash /home/mpetrick/repos/esp/esp-idf/examples/get-started/blink/build/CMakeFiles/flash 
cd /home/mpetrick/repos/esp/esp-idf/components/esptool_py && /usr/bin/cmake -D IDF_PATH=/home/mpetrick/repos/esp/esp-idf -D "SERIAL_TOOL=/home/mpetrick/.espressif/python_env/idf5.3_py3.11_env/bin/python;;/home/mpetrick/repos/esp/esp-idf/components/esptool_py/esptool/esptool.py;--chip;esp32" -D "SERIAL_TOOL_ARGS=--before=default_reset;--after=hard_reset;write_flash;@flash_args" -D WORKING_DIRECTORY=/home/mpetrick/repos/esp/esp-idf/examples/get-started/blink/build -P /home/mpetrick/repos/esp/esp-idf/components/esptool_py/run_serial_tool.cmake
ninja: build stopped: subcommand failed.
ninja failed with exit code 1, output of the command is in the /home/mpetrick/repos/esp/esp-idf/examples/get-started/blink/build/log/idf_py_stderr_output_32056 and /home/mpetrick/repos/esp/esp-idf/examples/get-started/blink/build/log/idf_py_stdout_output_32056
    ~/repos/esp/esp-idf/examples/get-started/blink    master !8  history                                                                                                                                                       2 ✘ 
 1394  ls -lah
 1395  cd get-started
 1398  cd blink
 1399  ls
 1400  idf.py menuconfig
 1403  sudo usermod -a -G dialout $USER
 1404  sudo idf.py flash
 1405  sudo usermod -a -G uucp $USER
 1407  sudo usermod -a -G uucp $USER\n
 1408  getent uucp
 1409  sudo getent uucp
 1410  getent group uucp\n
 1411  sudo chmod a+rw /dev/ttyACM0
 1413  idf.py set-target esp32c6\n
 1414  idf.py build
 1415  idf.py flash
    ~/repos/esp/esp-idf/examples/get-started/blink    master !8 
```
