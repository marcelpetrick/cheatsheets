# Raspberry Pi-related things

## hints
* get the aluminium block with thermal paste: <https://www.arrow.com/en/research-and-events/articles/raspberry-pi-4-cooling-solutions-comparison>

## Raspbian

### show desktop
* CTRL+ALT+D

## prepare wifi hotspot after SSH-in
```bash
Create hotspot:	sudo nmcli dev wifi hotspot ifname wlan0 ssid fancyssid password "alohabahoa"
Share internet:	sudo nmcli connection modify Hotspot ipv4.method shared
Auto-start at boot:	sudo nmcli connection modify Hotspot connection.autoconnect yes
Stop hotspot:	sudo nmcli connection down Hotspot
```
