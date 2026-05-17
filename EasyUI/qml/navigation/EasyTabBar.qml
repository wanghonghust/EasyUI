import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Effects
import EasyUI 1.0

Rectangle {
    id: root

    property var tabs: []
    property int currentIndex: 0
    property bool addable: true
    property int size: EasyTheme.size.sizeNormal

    signal tabClicked(int index)
    signal tabClosed(int index)
    signal addClicked()

    readonly property int computedHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return 36
        case EasyTheme.size.sizeSmall:  return 40
        case EasyTheme.size.sizeLarge:  return 48
        default:                        return 44
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
    readonly property int computedHPadding: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return 10
        case EasyTheme.size.sizeSmall:  return 12
        case EasyTheme.size.sizeLarge:  return 18
        default:                        return 14
        }
    }

    height: computedHeight + bottomLine.height
    color: "transparent"

    // Bottom border
    Rectangle {
        id: bottomLine
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1
        color: EasyTheme.color.divider
    }

    RowLayout {
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: bottomLine.top }
        spacing: 0

        // Left spacer
        Item { Layout.preferredWidth: 4; Layout.fillHeight: true }

        ListView {
            id: tabList
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            clip: true
            model: root.tabs
            spacing: 4

            delegate: Item {
                width: tabPill.width
                height: tabList.height

                readonly property bool isActive: index === root.currentIndex

                // Pill background
                Rectangle {
                    id: tabPill
                    anchors.verticalCenter: parent.verticalCenter
                    width: tabRow.implicitWidth + root.computedHPadding * 2
                    height: parent.height - 8
                    radius: height / 2

                    color: {
                        if (isActive) return EasyTheme.color.card
                        if (hoverArea.containsMouse) return EasyTheme.color.hover
                        return "transparent"
                    }

                    // Active tab subtle depth
                    layer.enabled: isActive
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: EasyTheme.color.shadow
                        shadowOpacity: EasyTheme.isDark ? 0.10 : 0.04
                        shadowBlur: 0.5
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 1
                    }

                    Behavior on color { ColorAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease } }

                    // Background click — must be first so Row content stacks on top
                    MouseArea {
                        id: hoverArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.currentIndex = index
                            root.tabClicked(index)
                        }
                    }

                    // Tab content
                    Row {
                        id: tabRow
                        anchors.centerIn: parent
                        spacing: 7
                        z: 1

                        EasyIconFont {
                            visible: modelData.icon !== undefined && modelData.icon !== ""
                            icon: modelData.icon || ""
                            iconSize: root.computedFontSize + 1
                            color: isActive ? EasyTheme.color.text : EasyTheme.color.placeholder
                            Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }
                        }

                        Text {
                            text: modelData.title || ""
                            font.pixelSize: root.computedFontSize
                            font.family: EasyTheme.font.family
                            color: isActive ? EasyTheme.color.text : EasyTheme.color.placeholder
                            Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Close button — always visible on active, hover on inactive
                        Rectangle {
                            visible: modelData.closable !== false && (isActive || closeMouse.containsMouse || hoverArea.containsMouse)
                            width: root.computedFontSize + 4
                            height: width
                            radius: width / 2
                            color: closeMouse.containsMouse
                                ? EasyTheme.color.buttonHover
                                : "transparent"
                            anchors.verticalCenter: parent.verticalCenter
                            opacity: isActive ? 1 : (closeMouse.containsMouse || hoverArea.containsMouse ? 1 : 0)
                            Behavior on opacity { NumberAnimation { duration: EasyTheme.transition.fast } }
                            Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }

                            EasyIconFont {
                                anchors.centerIn: parent
                                icon: EasyIcon.material.close
                                iconSize: root.computedFontSize - 2
                                color: closeMouse.containsMouse ? EasyTheme.color.text : EasyTheme.color.placeholder
                            }

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                anchors.margins: -4
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mouse => {
                                    mouse.accepted = true
                                    root.tabClosed(index)
                                }
                            }
                        }
                    }
                }

            }
        }

        // Add button
        Rectangle {
            visible: root.addable
            Layout.preferredWidth: computedHeight - 12
            Layout.preferredHeight: computedHeight - 12
            Layout.leftMargin: 6
            Layout.rightMargin: 4
            Layout.alignment: Qt.AlignVCenter
            radius: height / 2
            color: addHover.containsMouse ? EasyTheme.color.hover : "transparent"
            Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }

            EasyIconFont {
                anchors.centerIn: parent
                icon: EasyIcon.material.add
                iconSize: root.computedFontSize
                color: addHover.containsMouse ? EasyTheme.color.text : EasyTheme.color.placeholder
                Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }
            }

            MouseArea {
                id: addHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.addClicked()
            }
        }
    }
}
