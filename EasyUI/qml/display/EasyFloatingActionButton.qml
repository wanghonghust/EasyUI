import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Effects
import EasyUI

Rectangle {
    id: root

    property string icon: "＋"
    property real iconSize: 24
    property color bgColor: EasyTheme.color.primary

    property bool mini: false

    implicitWidth: mini ? 40 : 56
    implicitHeight: mini ? 40 : 56
    radius: height / 2
    color: bgColor

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true; shadowBlur: 0.8; shadowColor: EasyTheme.color.shadow
        shadowHorizontalOffset: 0; shadowVerticalOffset: 0
    }

    scale: mouseArea.containsPress ? 0.9 : 1.0
    Behavior on scale { NumberAnimation { duration: 100 } }

    Behavior on color { ColorAnimation { duration: 150 } }

    Text {
        anchors.centerIn: parent; text: root.icon
        font.pixelSize: root.iconSize; color: "white"
    }

    MouseArea {
        id: mouseArea; anchors.fill: parent
        hoverEnabled: true; cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        onEntered: { root.color = Qt.darker(bgColor, 1.15) }
        onExited: { root.color = bgColor }
    }

    signal clicked()
}
