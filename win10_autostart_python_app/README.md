# One way to configure auto-start for Windows 10

Added a batch-file `start.bat`, which sets the execution policy for the powershell-script `setup.ps1`, which then creates the virtual environment and executes the main.py with parameterization. The batch is started via a link in the AutoStart-directory of user current user (just create a link and copy&paste it to that directory).  
When the system reboots and logs in, the after some seconds (not immediately!) a terminal opens, where you can follow the output.
