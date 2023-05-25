# Tricks for Qt

## QTest

* find certain test out of a suite
```
./SUITENAME -functions
```
* execute with
```
./SUITENAME TESTNAME
```

## version info as current git commit sha1

### into pro/pri
```
GIT_CURRENT_SHA1 = $$system(git rev-parse --short=8 HEAD)
message( GIT_CURRENT_SHA1: ($$GIT_CURRENT_SHA1) )
DEFINES += GIT_SHA1=0x$$GIT_CURRENT_SHA1
```

### into cpp
```return QString("debug %1").arg(VERSION_GIT_SHA1, 6, 16, QChar('0'));;```

## Reboot/power off via 'systemctl' on embedded system with non-root (DBus did not really work ..)
```
    static void restart()
    {
        ::sync();

        auto const command = QStringList({ QStringLiteral("reboot") });
        QProcess process;
        process.start("systemctl", command);
        if (!process.waitForFinished()) {
            qWarning() << "Error executing" << command;
        } else {
            if (process.exitCode() != 0) {
                qWarning() << "Error executing" << command << "with exitcode" << process.exitCode();
            } else {
                qDebug() << "successfully executed" << command;
            }
        }
    }
```
Replace 'reboot' with 'poweroff' in case of shutdown.

## Internationalization
```
QObject::tr() und QCoreApplication::translate() have two responsibilities

    they are markers for stings that lupdate needs to extract
    they do runtime lookup of translatons

Code that is not executed during program runtime (e.g. global statics) or only once (function statics), need to have these two split:

    marking via QT_TR_NOOP or QT_TRANSLATE_NOOP
    lookup via one of the two runtime functions
```

### update all ts-files and remove leftover stuff
`~/XYZ/Qt/5.15.5/gcc_64/bin/lupdate -no-obsolete ~/XYZ/03_SourceCode/hmi/hmi.pro`

