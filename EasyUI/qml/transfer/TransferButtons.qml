import QtQuick
import QtQuick.Layouts
import EasyUI

/**
 * TransferButtons —— 穿梭框中间操作按钮
 */
Column {
    id: root

    property bool canMoveRight: false
    property bool canMoveLeft: false

    signal moveRight()
    signal moveLeft()

    spacing: EasyTheme.size.paddingSmall

    TransferButton {
        text: ">"
        enabled: root.canMoveRight
        onClicked: root.moveRight()
    }

    TransferButton {
        text: "<"
        enabled: root.canMoveLeft
        onClicked: root.moveLeft()
    }
}