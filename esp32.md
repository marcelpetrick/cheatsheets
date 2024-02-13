# hints for the Espressif ESP32

## get info which device was attached
```
lsusb > lsusb_before.txt
lsusb > lsusb_after.txt
diff lsusb_before.txt lsusb_after.txt

> Bus 001 Device 011: ID 303a:1001 Espressif USB JTAG/serial debug unit
```
