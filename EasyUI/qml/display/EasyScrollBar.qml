import QtQuick
import QtQuick.Controls.Basic
import EasyUI

ScrollBar {
    id: root

    property bool expandOnHover: true
    property int normalSize: 6
    property int hoverSize: 10

    policy: ScrollBar.AsNeeded
    active: size < 1.0

    readonly property real _effectiveSize: expandOnHover && (hovered || pressed) ? hoverSize : normalSize
    implicitWidth: vertical ? _effectiveSize : 0
    implicitHeight: vertical ? 0 : _effectiveSize

    // Hide when uninitialized or content fits (size=0 means not yet measured)
    opacity: size > 0 && size < 1.0 ? 1.0 : 0.0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    // Manual anchors — required for custom ScrollBar in ScrollView
    Component.onCompleted: {
        if (vertical) {
            anchors.top = Qt.binding(() => parent.top)
            anchors.bottom = Qt.binding(() => parent.bottom)
            anchors.right = Qt.binding(() => parent.right)
        } else {
            anchors.left = Qt.binding(() => parent.left)
            anchors.right = Qt.binding(() => parent.right)
            anchors.bottom = Qt.binding(() => parent.bottom)
        }
    }

    // Rectangular thumb
    contentItem: Rectangle {
        implicitWidth: root.vertical ? root._effectiveSize : 30
        implicitHeight: root.vertical ? 30 : root._effectiveSize
        radius: 3
        color: Qt.rgba(0.5, 0.5, 0.5, EasyTheme.isDark ? 0.45 : 0.42)
        opacity: root.pressed ? 0.9 : (root.hovered ? 0.7 : 1.0)
        Behavior on opacity { NumberAnimation { duration: 150 } }
        Behavior on implicitWidth { enabled: root.vertical; NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        Behavior on implicitHeight { enabled: !root.vertical; NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    // Transparent track
    background: Rectangle {
        anchors.fill: parent
        color: "transparent"
    }

    onHoveredChanged: {
        if (expandOnHover && (hovered || pressed)) {
            if (vertical) contentItem.implicitWidth = hoverSize
            else contentItem.implicitHeight = hoverSize
        } else {
            if (vertical) contentItem.implicitWidth = normalSize
            else contentItem.implicitHeight = normalSize
        }
    }
    onPressedChanged: {
        if (expandOnHover && (hovered || pressed)) {
            if (vertical) contentItem.implicitWidth = hoverSize
            else contentItem.implicitHeight = hoverSize
        } else {
            if (vertical) contentItem.implicitWidth = normalSize
            else contentItem.implicitHeight = normalSize
        }
    }
}
