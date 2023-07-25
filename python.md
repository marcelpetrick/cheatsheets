# activate venv
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
