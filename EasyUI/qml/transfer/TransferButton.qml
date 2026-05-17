import QtQuick
import EasyUI

/**
 * TransferButton —— 单个方向按钮
 */
Rectangle {
    id: root

    property string text: ""
    property bool enabled: false

    signal clicked()

    width: 32
    height: 32
    radius: EasyTheme.size.radius
    color: root.enabled
           ? (hoverArea.containsMouse ? EasyTheme.color.primaryLight : EasyTheme.color.primary)
           : EasyTheme.color.hover
    border.color: root.enabled ? EasyTheme.color.primary : EasyTheme.color.border
    border.width: EasyTheme.size.borderWidth

    Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }
    Behavior on border.color { ColorAnimation { duration: EasyTheme.transition.fast } }

    scale: hoverArea.containsMouse && root.enabled ? 1.05 : 1.0
    Behavior on scale { NumberAnimation { duration: EasyTheme.transition.instant } }

    EasyIconFont {
        anchors.centerIn: parent
        icon: root.text === ">" ? EasyIcon.material.chevron_right : EasyIcon.material.chevron_left
        iconSize: 18
        color: root.enabled ? EasyTheme.color.white : EasyTheme.color.placeholder
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (root.enabled) root.clicked()
    }
}