# How to get it up and running on a hybrid Intel/Nvidia setup with Manjaor Linux
* install the non-free drivers
* make sure to upgrade to latest kernel, etc and update all packages
* reboot
* btop and glmark2 shakll support now both cards ..

## setup and configure
* clone the repo
* python -m venv venv\nsource venv/bin/activate\npip install -r requirements.txt\n
* python --version
* python main.py\n


```
 python main.py                                                                      ✔  ComfyUI  

Checkpoint files will always be loaded safely.
Total VRAM 7842 MB, total RAM 31759 MB
pytorch version: 2.9.1+cu128
Set vram state to: NORMAL_VRAM
Device: cuda:0 NVIDIA RTX A2000 8GB Laptop GPU : cudaMallocAsync
Using async weight offloading with 2 streams
Enabled pinned memory 30170.0
working around nvidia conv3d memory bug.
Using pytorch attention
Python version: 3.13.7 (main, Aug 15 2025, 12:34:02) [GCC 15.2.1 20250813]
ComfyUI version: 0.4.0
ComfyUI frontend version: 1.34.8
[Prompt Server] web root: /home/mpetrick/repos/ComfyUI/venv/lib/python3.13/site-packages/comfyui_frontend_package/static
Total VRAM 7842 MB, total RAM 31759 MB
pytorch version: 2.9.1+cu128
Set vram state to: NORMAL_VRAM
Device: cuda:0 NVIDIA RTX A2000 8GB Laptop GPU : cudaMallocAsync
Using async weight offloading with 2 streams
Enabled pinned memory 30170.0

Import times for custom nodes:
   0.0 seconds: /home/mpetrick/repos/ComfyUI/custom_nodes/websocket_image_save.py

Context impl SQLiteImpl.
Will assume non-transactional DDL.
No target revision found.
Starting server

To see the GUI go to: http://127.0.0.1:8188
```


## model problems
* test with photo: flux v2
  * download all of them (from the dialog)
  * where to place them?
