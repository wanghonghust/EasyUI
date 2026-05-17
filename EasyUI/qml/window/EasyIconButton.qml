import QtQuick 2.15
import EasyUI 1.0

Rectangle {
    id: root
    property int btnRadius: EasyTheme.size.radius

    width: 30
    height: 30
    radius: btnRadius
    color: mouseArea.containsMouse ? root.hoverColor : "transparent"

    property string hoverColor: "transparent"
    property string icon: ""
    property bool enabled: true
    signal clicked()
    signal hoverChanged(bool isHover)

    readonly property bool _isSymbolChar: icon.length === 1 && icon.charCodeAt(0) >= 0xE000

    Behavior on color { ColorAnimation { duration: 150 } }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        onClicked: {
            if (root.enabled) root.clicked()
        }
        onHoveredChanged: root.hoverChanged(containsMouse)
    }

    // Image path mode
    Image {
        id: buttonIcon
        anchors.centerIn: parent
        width: 18
        height: 18
        source: root._isSymbolChar ? "" : root.icon
        fillMode: Image.PreserveAspectFit
        sourceSize: Qt.size(64, 64)
        visible: !root._isSymbolChar
    }

    // Material Symbols PUA character mode
    Text {
        anchors.centerIn: parent
        text: root._isSymbolChar ? root.icon : ""
        font.family: "Material Symbols Outlined"
        font.pixelSize: 18
        color: EasyTheme.color.text
        renderType: Text.NativeRendering
        visible: root._isSymbolChar
    }
}
