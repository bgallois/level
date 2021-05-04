import QtQuick 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.15
import QtSensors 5.15

FocusScope {
    property Camera camera
    property Gyroscope gyro
    property Rectangle disp
    property int overlay: 0

    property int buttonsPanelWidth: buttonPaneShadow.width

    id : captureControls

    Row {
        id: buttonPaneShadow
        spacing: 14
        height: 200
        anchors.horizontalCenter: parent.horizontalCenter

        RoundButton {
            id: cameraListButton
            height: 200
            width: 200
            property int current: 0
            text: "Camera"
            onClicked: {
                (current < QtMultimedia.availableCameras.length-1) ? ++current : current = 0;
                camera.deviceId = QtMultimedia.availableCameras[current].deviceId;
            }
        }

        RoundButton {
            id: axisButton
            height: 200
            width: 200
            text: "Overlay"
            onClicked: {
                (overlay < 2) ? ++overlay : overlay = 0;
            }
        }

        RoundButton {
            id: focusButton
            height: 200
            width: 200
            onClicked: {
                (camera.lockStatus == Camera.Unlocked) ? camera.searchAndLock() : camera.unlock();
            }

            text: {
                if (camera.lockStatus == Camera.Unlocked)
                    "Focus";
                else if (camera.lockStatus == Camera.Searching)
                    "Focusing"
                else
                    "Unlock"
            }
        }

        RoundButton {
            id: takeButton
            height: 200
            width: 200
            text: "Photo"
            onClicked: {
                disp.screenshot()
            }
        }

        RoundButton {
            id: levelButton
            height: 200
            width: 200
            text: "Level"
            onClicked: {
                gyro.zLevel = 0;
                gyro.yLevel = 0;
                gyro.xLevel = 0;
            }
        }
    }
}
