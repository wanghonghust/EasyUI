import QtQuick
import EasyUI

Rectangle {
    id: root

    property string text: ""
    property bool closable: false
    property string type: "primary"
    property int size: EasyTheme.size.sizeNormal

    readonly property int computedHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.tagHeightMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.tagHeightSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.tagHeightLarge
        default:                        return EasyTheme.size.tagHeightNormal
        }
    }
    readonly property int computedFontSize: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.fontSizeMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.fontSizeSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.fontSizeLarge
        default:                        return EasyTheme.size.fontSizeNormal
        }
    }
    readonly property int hPadding: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return 6
        case EasyTheme.size.sizeSmall:  return 8
        case EasyTheme.size.sizeLarge:  return 12
        default:                        return 10
        }
    }

    implicitHeight: computedHeight
    implicitWidth: row.implicitWidth + hPadding * 2
    radius: EasyTheme.size.radiusSmall

    // Color by type
    property color typeColor: {
        switch(type) {
            case "success": return EasyTheme.color.success
            case "warning": return EasyTheme.color.warning
            case "error":   return EasyTheme.color.colorError
            case "info":    return EasyTheme.color.info
            default:        return EasyTheme.color.primary
        }
    }

    property color typeBg: Qt.rgba(typeColor.r, typeColor.g, typeColor.b, 0.10)
    property color typeBorder: Qt.rgba(typeColor.r, typeColor.g, typeColor.b, 0.20)

    color: typeBg
    border.color: typeBorder
    border.width: EasyTheme.size.borderWidth

    Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }
    Behavior on border.color { ColorAnimation { duration: EasyTheme.transition.fast } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: closable ? 4 : 0

        Text {
            text: root.text
            font.pixelSize: computedFontSize
            font.family: EasyTheme.font.family
            color: root.typeColor
            anchors.verticalCenter: parent.verticalCenter
        }

        // Close button
        EasyIconFont {
            visible: root.closable
            icon: EasyIcon.material.close
            iconSize: computedFontSize + 1
            color: closeArea.containsMouse ? "white" : root.typeColor
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.centerIn: parent
                width: parent.iconSize + 4
                height: parent.iconSize + 4
                radius: width / 2
                color: closeArea.containsMouse ? root.typeColor : "transparent"
                z: -1
                Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }
            }

            MouseArea {
                id: closeArea
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                onClicked: root.closed()
            }
        }
    }

    signal closed()
}
