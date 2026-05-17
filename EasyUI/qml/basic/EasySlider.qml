import QtQuick
import QtQuick.Effects
import EasyUI

Rectangle {
    id: root

    property real value: 0
    property real from: 0
    property real to: 100
    property bool enabled: true
    property bool integer: true
    property int stepSize: 1
    property int size: EasyTheme.size.sizeNormal

    readonly property int computedTrackHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return 3
        case EasyTheme.size.sizeSmall:  return 4
        case EasyTheme.size.sizeLarge:  return 6
        default:                        return 4
        }
    }
    readonly property int computedHandleSize: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return 12
        case EasyTheme.size.sizeSmall:  return 14
        case EasyTheme.size.sizeLarge:  return 20
        default:                        return 16
        }
    }

    implicitWidth: 200
    implicitHeight: computedHandleSize + 8
    color: "transparent"
    opacity: root.enabled ? 1.0 : 0.45

    Behavior on opacity { NumberAnimation { duration: EasyTheme.transition.fast } }

    property bool _dragging: false

    // Track
    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: computedTrackHeight
        radius: height / 2
        color: EasyTheme.color.border

        Rectangle {
            id: filledTrack
            // Fill to the center of the handle
            width: (root.value - root.from) / (root.to - root.from) * (parent.width - handle.width) + handle.width / 2
            height: parent.height
            radius: height / 2
            color: EasyTheme.color.primary
            Behavior on width {
                enabled: !root._dragging
                NumberAnimation { duration: EasyTheme.transition.fast }
            }
        }
    }

    // Handle
    Rectangle {
        id: handle
        width: computedHandleSize
        height: computedHandleSize
        radius: width / 2
        color: _dragging ? Qt.darker(EasyTheme.color.primary, 1.05) : "white"
        border.color: EasyTheme.color.primary
        border.width: _dragging ? 3 : 2
        scale: _dragging ? 1.15 : 1.0
        anchors.verticalCenter: parent.verticalCenter
        x: (root.value - root.from) / (root.to - root.from) * (root.width - width)

        // Animate only when not dragging
        Behavior on x {
            enabled: !root._dragging
            NumberAnimation { duration: EasyTheme.transition.fast }
        }
        Behavior on scale { NumberAnimation { duration: EasyTheme.transition.instant } }
        Behavior on border.width { NumberAnimation { duration: EasyTheme.transition.instant } }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#000000"
            shadowOpacity: root._dragging ? 0.24 : 0.14
            shadowBlur: root._dragging ? 1.0 : 0.5
            shadowHorizontalOffset: 0
            shadowVerticalOffset: root._dragging ? 2 : 1
        }
    }

    MouseArea {
        id: sliderMouseArea
        anchors.fill: parent
        anchors.topMargin: -computedHandleSize
        anchors.bottomMargin: -computedHandleSize
        enabled: root.enabled
        preventStealing: true

        onPressed: function(mouse) {
            mouse.accepted = true
            root._dragging = true
            updateValue(mouse.x)
        }
        onPositionChanged: function(mouse) {
            if (mouse.buttons & Qt.LeftButton) {
                updateValue(mouse.x)
            }
        }
        onReleased: {
            root._dragging = false
            if (root.integer && root.stepSize > 1) {
                var stepped = Math.round(root.value / root.stepSize) * root.stepSize
                root.value = Math.max(root.from, Math.min(root.to, stepped))
            }
            root.valueEdited(root.value)
        }

        function updateValue(mouseX) {
            var ratio = Math.max(0, Math.min(1, mouseX / root.width))
            var newValue = root.from + ratio * (root.to - root.from)
            if (root.integer) {
                newValue = Math.round(newValue / root.stepSize) * root.stepSize
            }
            root.value = Math.max(root.from, Math.min(root.to, newValue))
            root.valueEdited(root.value)
        }
    }

    Keys.onLeftPressed: {
        if (root.enabled) {
            root.value = Math.max(root.from, root.value - root.stepSize)
            root.valueEdited(root.value)
        }
    }
    Keys.onRightPressed: {
        if (root.enabled) {
            root.value = Math.min(root.to, root.value + root.stepSize)
            root.valueEdited(root.value)
        }
    }

    signal valueEdited(real value)
}
