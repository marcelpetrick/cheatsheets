# tricks for Qt

## version info as current git commit sha1

### into pro/pri
```
GIT_CURRENT_SHA1 = $$system(git rev-parse --short=8 HEAD)
message( GIT_CURRENT_SHA1: ($$GIT_CURRENT_SHA1) )
DEFINES += GIT_SHA1=0x$$GIT_CURRENT_SHA1
```

### into cpp
```return QString("debug %1").arg(VERSION_GIT_SHA1, 6, 16, QChar('0'));;```
