import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI 1.0

Rectangle {
    id: emb

    readonly property int leftPadding: 10
    readonly property int rightPadding: 10

    color: emb.active ? EasyTheme.color.primary : (emb.hovered ? hoverColor : bgColor)
    radius: barRadius

    property int barWidth: 0
    property int extraLeftPadding: 0
    property int barHeight: 38
    property int barRadius: 8
    property color hoverColor: EasyTheme.color.menuHover
    property color bgColor: EasyTheme.color.background
    property bool active: false
    property bool hovered: false
    property color actveTextColor: EasyTheme.color.menuActiveText

    property string title
    property string icon: ""             // 字体图标 Unicode，如 "\ue88a"
    property alias iconTail: tailIcon.icon
    property bool enabled: true

    signal clicked

    // 延迟计时器
    Timer {
        id: showTimer
        interval: 500 // 500ms 延迟
        onTriggered: {
            if (mouseArea.containsMouse && name.truncated) {
                var pos = name.mapToItem(Overlay.overlay, 0, 0)
                hoverTextBg.x = pos.x
                hoverTextBg.y = pos.y - hoverTextBg.height - 5
                hoverTextBg.visible = true
            }
        }
    }

    RowLayout {
        id: rowLayout
        width: parent.width
        height: emb.barHeight
        spacing: 10

        EasyIconFont {
            id: buttonIcon
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
            Layout.leftMargin: emb.leftPadding + emb.extraLeftPadding
            Layout.alignment: Qt.AlignVCenter
            icon: emb.icon
            iconSize: 18
            color: emb.active ? EasyTheme.color.menuActiveText : EasyTheme.color.text
        }

        Text {
            id: name
            Layout.fillWidth: true
            Layout.fillHeight: true
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
            text: title || qsTr("text")
            color: emb.active ? EasyTheme.color.menuActiveText : EasyTheme.color.text
            font.pixelSize: 16
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
        }

        EasyIconFont {
            id: tailIcon
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
            Layout.rightMargin: emb.rightPadding
            Layout.alignment: Qt.AlignVCenter
            iconSize: 18
            color: emb.active ? EasyTheme.color.menuActiveText : EasyTheme.color.secondary
        }
    }

    Rectangle {
        id: hoverTextBg
        parent: Overlay.overlay
        visible: false
        color: "#333"
        radius: 4
        height: 30
        width: hoverText.implicitWidth + 20
        z: 9999
        opacity: 0 // 初始透明

        // 显示/隐藏动画
        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
        onVisibleChanged: opacity = visible ? EasyTheme.size.borderWidthActive : 0

        Text {
            id: hoverText
            anchors.centerIn: parent
            text: emb.title
            color: "white"
            font.pixelSize: 14
        }
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: emb.enabled
        anchors.fill: parent
        cursorShape: emb.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        onClicked: {
            if (emb.enabled) emb.clicked()
        }

        onEntered: {
            emb.hovered = true
            if (name.truncated) {
                showTimer.start() // 启动延迟计时
            }
        }

        onExited: {
            emb.hovered = false
            showTimer.stop() // 取消延迟
            hoverTextBg.visible = false
        }
    }
}
