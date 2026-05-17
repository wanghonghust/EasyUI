import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Effects
import EasyUI

Rectangle {
    id: root

    // ── Model: array of { text, icon, disabled, divided, onClick }
    property var model: []
    property string trigger: "click" // "click" | "hover"
    property string placement: "bottom-start" // "bottom-start" | "bottom" | "bottom-end" | "top-start"
    property int size: EasyTheme.size.sizeNormal
    property real popupWidth: 0
    property real minWidth: 140
    property real maxHeight: 300
    property bool disabled: false

    readonly property int computedItemHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:
            return EasyTheme.size.optionHeightMini
        case EasyTheme.size.sizeSmall:
            return EasyTheme.size.optionHeightSmall
        case EasyTheme.size.sizeLarge:
            return EasyTheme.size.optionHeightLarge
        default:
            return EasyTheme.size.optionHeightNormal
        }
    }

    readonly property int computedHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:
            return EasyTheme.size.heightMini
        case EasyTheme.size.sizeSmall:
            return EasyTheme.size.heightSmall
        case EasyTheme.size.sizeLarge:
            return EasyTheme.size.heightLarge
        default:
            return EasyTheme.size.heightNormal
        }
    }
    readonly property int computedFontSize: {
        switch (size) {
        case EasyTheme.size.sizeMini:
            return EasyTheme.size.fontSizeMini
        case EasyTheme.size.sizeSmall:
            return EasyTheme.size.fontSizeSmall
        case EasyTheme.size.sizeLarge:
            return EasyTheme.size.fontSizeLarge
        default:
            return EasyTheme.size.fontSizeNormal
        }
    }
    readonly property int computedPadding: {
        switch (size) {
        case EasyTheme.size.sizeMini:
            return 8
        case EasyTheme.size.sizeSmall:
            return 10
        case EasyTheme.size.sizeLarge:
            return 14
        default:
            return 12
        }
    }

    // ── trigger-area slot alias ──
    default property alias content: triggerArea.data

    implicitWidth: triggerArea.childrenRect.width
    height: triggerArea.childrenRect.height
    color: "transparent"

    // ── Internal popup track
    property bool _popupOpen: false
    property int _hoverCount: 0

    Item {
        id: triggerArea
        width: childrenRect.width
        height: childrenRect.height

        property bool _triggerHovered: false

        // Hover timer (for trigger: hover)
        Timer {
            id: hoverTimer
            interval: 150
            onTriggered: openPopup()
        }

        // Close-delay timer (hover mode)
        Timer {
            id: closeDelayTimer
            interval: 200
            onTriggered: {
                if (root._hoverCount === 0 && !triggerArea._triggerHovered)
                    closePopup()
            }
        }

        // Click capture — on top of children (z:10). hoverEnabled:false so children get hover.
        MouseArea {
            id: triggerAreaMouse
            z: 10
            anchors.fill: parent
            enabled: root.trigger === "click" && !root.disabled
                     && root.model.length > 0
            hoverEnabled: false
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                if (root._popupOpen)
                    closePopup()
                else
                    openPopup()
            }
        }
    }

    // Hover detection — non-blocking, children's hover works normally
    HoverHandler {
        id: triggerHover
        enabled: !root.disabled && root.model.length > 0
        onHoveredChanged: {
            triggerArea._triggerHovered = hovered
            if (hovered) {
                if (root.trigger === "hover" && !root._popupOpen)
                    hoverTimer.start()
                closeDelayTimer.stop()
            } else {
                hoverTimer.stop()
                if (root.trigger === "hover")
                    closeDelayTimer.restart()
            }
        }
    }

    function openPopup() {
        if (root.disabled || root.model.length === 0)
            return
        dropdownPopup.open()
        root._popupOpen = true
    }

    function closePopup() {
        dropdownPopup.close()
        root._popupOpen = false
    }

    Popup {
        id: dropdownPopup
        width: root.popupWidth > 0 ? root.popupWidth : Math.max(root.minWidth,
                                                                root.width)
        height: Math.min(maxHeight,
                         menuCol.implicitHeight + dropdownPopup.padding * 2)
        padding: 8
        clip: true
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape

        transformOrigin: _dropUp ? Item.Bottom : Item.Top

        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0; to: 1
                duration: EasyTheme.transition.fast
                easing.type: EasyTheme.transition.ease
            }
            NumberAnimation {
                property: "scale"
                from: 0.92; to: 1
                duration: EasyTheme.transition.normal
                easing.type: Easing.OutBack
            }
        }
        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1; to: 0
                duration: EasyTheme.transition.fast
                easing.type: Easing.InCubic
            }
        }

        property bool _dropUp: false

        Timer {
            id: positionTimer
            interval: 50
            running: dropdownPopup.visible
            repeat: true
            onTriggered: dropdownPopup.updateDropDirection()
        }

        function updateDropDirection() {
            var posInWindow = root.mapToItem(null, 0, root.height)
            var bottomInWindow = posInWindow.y
            var windowH = root.Window.height || 600
            _dropUp = (bottomInWindow + height + 4) > windowH
        }

        onAboutToShow: updateDropDirection()

        x: {
            if (placement === "bottom-end")
                return root.width - width
            return 0
        }
        y: _dropUp ? -(height + 4) : (root.height + 4)

        onVisibleChanged: {
            if (!visible)
                root._popupOpen = false
        }

        background: Rectangle {
            radius: EasyTheme.size.radius
            color: EasyTheme.color.card
            border.width: 1
            border.color: EasyTheme.color.border
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: EasyTheme.color.shadow
                shadowOpacity: EasyTheme.elevation.shadowOpacity(EasyTheme.elevation.medium)
                shadowBlur: 0.5
                shadowVerticalOffset: EasyTheme.elevation.shadowOffsetY(EasyTheme.elevation.medium)
                shadowHorizontalOffset: 0
            }
        }

        Column {
            id: menuCol
            width: dropdownPopup.width - dropdownPopup.padding * 2
            spacing: 2

            Repeater {
                model: root.model
                delegate: Item {
                    width: menuCol.width
                    height: modelData.divider ? 1 + 4 : root.computedItemHeight
                    visible: modelData.visible !== false

                    // Divider
                    Rectangle {
                        visible: modelData.divider === true
                        width: parent.width - 8
                        height: 1
                        anchors.centerIn: parent
                        color: EasyTheme.color.divider
                    }

                    // Menu item
                    Rectangle {
                        visible: !modelData.divider
                        anchors.fill: parent
                        radius: EasyTheme.size.radiusSmall
                        color: {
                            if (modelData.disabled)
                                return "transparent"
                            if (itemHover.containsMouse)
                                return EasyTheme.color.menuHover
                            return "transparent"
                        }
                        opacity: modelData.disabled ? 0.4 : 1.0

                        Behavior on color {
                            ColorAnimation { duration: EasyTheme.transition.fast }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8

                            EasyIconFont {
                                visible: modelData.icon !== undefined
                                icon: modelData.icon || ""
                                iconSize: root.computedFontSize + 2
                                color: modelData.disabled ? EasyTheme.color.placeholder : EasyTheme.color.text
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                text: modelData.text || ""
                                font.pixelSize: root.computedFontSize
                                color: modelData.disabled ? EasyTheme.color.placeholder : EasyTheme.color.text
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        MouseArea {
                            id: itemHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: modelData.disabled ? Qt.ForbiddenCursor : Qt.PointingHandCursor
                            enabled: !modelData.disabled
                            onEntered: {
                                root._hoverCount++
                                closeDelayTimer.stop()
                            }
                            onExited: {
                                root._hoverCount--
                                if (root.trigger === "hover"
                                        && root._hoverCount <= 0)
                                    closeDelayTimer.restart()
                            }
                            onClicked: {
                                if (modelData.onClick)
                                    modelData.onClick()
                                root.closePopup()
                            }
                        }
                    }
                }
            }
        }
    }
}
