# git clean before 
` git reset --hard && git clean -xfd`

# prepare and activate venv
```
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt
```

# upgrade pip
`pip install --upgrade pip`

# proper logging
```
import logging

log_format = "%(asctime)s - [%(filename)s:%(lineno)d - %(funcName)s] - %(message)s"
logging.basicConfig(level=logging.INFO, format=log_format)

import os
logging.info(f"current working directory: {os.getcwd()}")
platform
logging.info(f"os: {platform.system()}")
```

# experiments to package Python-apps with Pyinstaller and Wine (host Linux, target Win) 20240222

* install `wine`: e.g. `sudo pacman -Sy wine`
* download Python installer for Windows from  `https://www.python.org/downloads/windows/`
* install: `wine python-3.11.8-amd64.exe`

` wine /home/mpetrick/.wine/drive_c/users/mpetrick/AppData/Local/Programs/Python/Python311/python.exe -m pip install pyinstaller  `

  WARNING: The scripts pyi-archive_viewer.exe, pyi-bindepend.exe, pyi-grab_version.exe, pyi-makespec.exe, pyi-set_version.exe and pyinstaller.exe are installed in 'C:\users\mpetrick\AppData\Local\Programs\Python\Python311\Scripts' which
 is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.

* installed depdendencies for wine as well
* testing the resulting executable:
```
    ~/repos/specpdfcreator/dist/gui    main ⇡1 *2  wine gui.exe                                                                                                     ✔ 
007c:fixme:wineusb:query_id Unhandled ID query type 0x5.
007c:fixme:wineusb:query_id Unhandled ID query type 0x5.
007c:fixme:wineusb:query_id Unhandled ID query type 0x5.
007c:fixme:wineusb:query_id Unhandled ID query type 0x5.
007c:fixme:wineusb:query_id Unhandled ID query type 0x5.
007c:fixme:wineusb:query_id Unhandled ID query type 0x5.
007c:fixme:wineusb:query_id Unhandled ID query type 0x5.
007c:fixme:wineusb:query_id Unhandled ID query type 0x5.
Traceback (most recent call last):
  File "gui.py", line 3, in <module>
ModuleNotFoundError: No module named 'PyQt5'
[276] Failed to execute script 'gui' due to unhandled exception!
0118:fixme:kernelbase:AppPolicyGetProcessTerminationMethod FFFFFFFFFFFFFFFA, 00007FFFFE2EFE80
    ~/repos/specpdfcreator/dist/gui    main ⇡1 *2 
 ```
