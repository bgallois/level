import QtQuick 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.15
import QtSensors 5.15
import QtQuick.Controls.Material 2.15
import Qt.labs.platform 1.1


ApplicationWindow {
    visible: true
    Material.theme: Material.Dark
    Material.accent: Material.Orange

    MessageDialog {
        id: errorBox
        title: "Error"
        visible: false
        onAccepted: {
            Qt.quit()
        }
    }

    Rectangle {
        id : cameraUI

        width: parent.width
        height: parent.height

        function screenshot() {
            grabToImage(function(result) {
                var d = new Date();
                var re = result.saveToFile((StandardPaths.writableLocation(StandardPaths.PicturesLocation)+"").replace('file://', '') + "/" + d.getTime()  +".png");
                // For targeting Android 11 (API level 30), the system ignores the requestLegacyExternalStorage attribute when your app is running on Android 11 devices, so your app must be ready to support scoped storage and to migrate app data for users on those devices.
                if (!re){
                    errorBox.text = "Can't write image to " + (StandardPaths.writableLocation(StandardPaths.PicturesLocation)+"").replace('file://', '') + "/" + d.getTime()  +".png";
                    errorBox.visible = true;
                }
            });
        }

        color: Material.background
        state: "PhotoCapture"

        states: [
            State {
                name: "PhotoCapture"
                StateChangeScript {
                    script: {
                        camera.captureMode = Camera.CaptureStillImage
                        camera.start()
                    }
                }
            }
        ]

        Timer {
            interval: 4; running: true; repeat: false
            onTriggered:{
                gyro.zLevel = 0;
                gyro.yLevel = 0;
                gyro.xLevel = 0;
            }
        }

        Camera {
            id: camera
            captureMode: Camera.CaptureStillImage
        }

        VideoOutput {
            id: viewfinder
            visible: cameraUI.state == "PhotoCapture"

            x: 0
            y: 0
            width: parent.width
            height: parent.height

            source: camera
            autoOrientation: true
        }

        PhotoCaptureControls {
            id: stillControls
            camera: camera
            width: parent.width
            gyro: gyro
            disp: cameraUI
            visible: cameraUI.state == "PhotoCapture"
            y: parent.height - 200
        }

        Slider{
            y : 50
            anchors.horizontalCenter: parent.horizontalCenter
            width : parent.width/1.5
            from: 1
            to: Math.min(4.0, camera.maximumDigitalZoom)
            value: camera.digitalZoom
            handle.height: 50
            handle.width: 50
            onValueChanged: camera.setDigitalZoom(value)
            Text {
                id: zoomLabel
                color: "white"
                text: qsTr("Zoom ") + Math.round(parent.value*10)/10 + " x"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
            }
        }

        Gyroscope {
           id: gyro
           active: true
           property real currentTime: 0
           property real zLevel: 0
           property real xLevel: 0
           property real yLevel: 0
           onReadingChanged: {
               zLevel += reading.z*(reading.timestamp-currentTime)*1E-6;
               xLevel += reading.x*(reading.timestamp-currentTime)*1E-6;
               yLevel += reading.y*(reading.timestamp-currentTime)*1E-6;
               currentTime = reading.timestamp;
           }
        }

        Item {
            id: overlay
            visible: true
            anchors.fill: parent

            Rectangle {
                id: hLevelRef
                width: parent.width
                height: 5
                y: parent.height*0.5
                color: "red"
                border.color: "red"
                border.width: 5
                radius: 10
                rotation: 0
                visible: stillControls.overlay == 0 || stillControls.overlay == 1
            }

            Rectangle {
                id: vLevelRef
                width: parent.width
                height: 5
                y: parent.height*0.5
                color: "green"
                border.color: "green"
                border.width: 5
                radius: 10
                visible: stillControls.overlay == 0  || stillControls.overlay == 2
                rotation: 90
            }


            Rectangle {
                id: hLevel
                width: parent.width
                height: 10
                y: parent.height*0.5+gyro.xLevel*4
                color: "red"
                border.color: "red"
                border.width: 5
                radius: 10
                visible: stillControls.overlay == 0  || stillControls.overlay == 1
                rotation: gyro.zLevel
                Text {
                    padding: 10
                    text: "Angle: " + Math.round(gyro.zLevel*10)/10 + "     Deviation: " + Math.round(gyro.xLevel*10)/10
                    textFormat: Text.RichText
                    color: "red"
                }
            }


            Rectangle {
                id: vLevel
                width: parent.width
                height: 10
                y: parent.height*0.5
                color: "green"
                border.color: "green"
                border.width: 5
                radius: 10
                visible: stillControls.overlay == 0  || stillControls.overlay == 2
                rotation: 90 + gyro.zLevel
                x: gyro.yLevel*4
                Text {
                    padding: 10
                    text: "Deviation: " + Math.round(gyro.yLevel*10)/10 + "     Angle: " + Math.round(gyro.zLevel*10)/10
                    color: "green"
                    textFormat: Text.RichText
                }
            }
        }
    }
}
