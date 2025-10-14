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

## update all ts-files and remove leftover stuff
`~/XYZ/Qt/5.15.5/gcc_64/bin/lupdate -no-obsolete ~/XYZ/03_SourceCode/hmi/hmi.pro`

## FPS-counter for QML

```qml
import QtQuick 2.15

Item {
    id: root
    property double fps: 0
    property int frames: 0
    property double lastUpdateMS: Date.now()
    property real tick: 0            // dummy animating value

    // Drive a per-frame tick
    NumberAnimation on tick {
        id: ticker
        from: 0
        to: 1
        duration: 1000000            // long, slow sweep; we only care about per-frame changes
        running: true
        loops: Animation.Infinite
    }

    onTickChanged: {
        frames++
        const now = Date.now()
        const dt = now - lastUpdateMS
        if (dt >= 500) {
            fps = frames * 1000.0 / dt
            frames = 0
            lastUpdateMS = now
        }
    }

    // overlay UI (top-left, always on top)
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 8
        radius: 6
        color: "#66000000"
        border.color: "#22FFFFFF"
        z: 9999
        Text {
            anchors.fill: parent
            anchors.margins: 6
            text: root.fps.toFixed(1) + " FPS"
            color: "black"
            font.bold: true
        }
    }
}
```

Use (to draw on top of everything):

```qml
    FpsOverlay {
        id: fps
        x: 0
        y: 0
        z: 9999    // large value ensures it's above other content
    }
```

## Qt5: no official package for Manjaor Linux: Qt5-Datavisualisation
* the first commands fail, therefore clone&build
```
sudo pacman -S qt5-datavis3d
sudo pacman -S qt5-datavisualization
sudo pacman -S qt5-datavis

echo "this works"
sudo pacman -S --needed base-devel git\n
cd ~ /repos
git clone https://aur.archlinux.org/qt5-datavis3d.git\ncd qt5-datavis3d\n
makepkg -si
```
