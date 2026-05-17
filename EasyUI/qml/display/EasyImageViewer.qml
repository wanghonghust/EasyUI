import QtQuick
import QtQuick.Controls.Basic
import EasyUI

Popup {
    id: root
    modal: true
    dim: true
    padding: 0
    closePolicy: Popup.OnEscape | Popup.OnPressOutside
    parent: Overlay.overlay
    anchors.centerIn: parent
    width: parent ? parent.width * 0.85 : 800
    height: parent ? parent.height * 0.85 : 600

    property url source: ""
    property real imgScale: 1.0
    property real minScale: 0.1
    property real maxScale: 10.0
    property real rotationAngle: 0

    onOpened: { imgScale = 1.0; rotationAngle = 0 }

    background: Rectangle {
        color: EasyTheme.color.card
        radius: 12
        border.color: EasyTheme.color.border
        border.width: EasyTheme.size.borderWidth

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: function(wheel) {
                var delta = wheel.angleDelta.y > 0 ? 0.15 : -0.15
                imgScale = Math.min(maxScale, Math.max(minScale, imgScale + delta))
            }
        }
    }

    contentItem: Item {
        clip: true

        Image {
            id: image
            source: root.source
            visible: source != "" && status === Image.Ready
            asynchronous: true
            anchors.centerIn: parent
            width: parent.width * 0.9; height: parent.height * 0.9
            fillMode: Image.PreserveAspectFit
            scale: imgScale; rotation: rotationAngle

            Behavior on scale { NumberAnimation { duration: 150 } }
            Behavior on rotation { NumberAnimation { duration: 200 } }
        }

        // Drag for panning
        DragHandler {
            target: image
            acceptedDevices: PointerDevice.Mouse | PointerDevice.Touch
            grabPermissions: PointerHandler.TakeOverForbidden
        }

        // Pinch to zoom
        PinchHandler {
            target: image
            onActiveChanged: { if (!active) return }
            minimumScale: root.minScale; maximumScale: root.maxScale
        }
    }

    // ── Toolbar ──
    Row {
        anchors { top: parent.top; right: parent.right; margins: 8 }
        spacing: 4; z: 10

        Repeater {
            model: [
                { icon: EasyIcon.material.zoom_in, tip: "放大", action: function() { imgScale = Math.min(maxScale, imgScale + 0.25) } },
                { icon: EasyIcon.material.zoom_out, tip: "缩小", action: function() { imgScale = Math.max(minScale, imgScale - 0.25) } },
                { icon: EasyIcon.material.rotate_right, tip: "旋转", action: function() { rotationAngle = (rotationAngle + 90) % 360 } },
                { icon: EasyIcon.material.refresh, tip: "重置", action: function() { imgScale = 1.0; rotationAngle = 0 } },
                { icon: EasyIcon.material.close, tip: "关闭", action: function() { root.close() } }
            ]
            delegate: Rectangle {
                width: 32; height: 32; radius: 6
                color: btnArea.containsMouse ? EasyTheme.color.buttonHover : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                EasyIconFont {
                    anchors.centerIn: parent
                    icon: modelData.icon
                    iconSize: 18
                    color: EasyTheme.color.text
                }
                MouseArea {
                    id: btnArea; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor; onClicked: modelData.action()
                }
            }
        }
    }
}
