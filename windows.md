# Cheat sheet for Windows

## Activate hibernate in case it is missing from any kind of Win10 energy-options/savings-menu
* terminal as admin (WIN + X)
```
powercfg /hibernate on
```
* worked? as a result the hiberfil.sys should be put to C:\\

## Show current computer's name (hostname)
```
cmd /k hostname
```

## Move window (without the menu bar)
Press ALT + SPACE, then select "Move window" and then use the cursor-keys

## Task manager
CTRL + SHIFT + ESC

## Show desktop
WIN + D

## Backup manually the VM to external SSD
```robocopy c:\Repos\kubuntu20.04 D:\vmBackups\20210423\ /MIR /MT:8```

## show path to certain executable
`where ssh`
