@echo off

rem Copy the Kubuntu VM to the private share

robocopy "kubuntu21.04" "H:\VMbackup" /ETA /MIR /MT:8

exit /b
