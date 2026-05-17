import QtQuick
import QtQuick.Controls.Basic
import EasyUI

Rectangle {
    id: root

    // ── 属性 ──
    property string text: ""
    property string icon: ""
    property int size: EasyTheme.size.sizeNormal
    property bool primary: true
    property bool enabled: true
    property bool loading: false
    property string type: ""         // "" | "success" | "warning" | "danger" | "plain"
    property string toolTipText: ""
    property bool round: false       // 圆形图标按钮
    property real padding: -1        // -1 = auto (use computed), >=0 = override

    // ── 尺寸计算 ──
    readonly property int computedHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.heightMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.heightSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.heightLarge
        default:                        return EasyTheme.size.heightNormal
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
    readonly property int computedPadding: {
        if (root.padding >= 0) return root.padding
        if (round) return 0
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.btnPaddingMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.btnPaddingSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.btnPaddingLarge
        default:                        return EasyTheme.size.btnPaddingNormal
        }
    }

    // ── 类型色 ──
    readonly property color typeColor: {
        switch (type) {
        case "success": return EasyTheme.color.success
        case "warning": return EasyTheme.color.warning
        case "danger":  return EasyTheme.color.colorError
        default:        return EasyTheme.color.primary
        }
    }
    readonly property color typeColorDark: Qt.darker(typeColor, 1.12)
    readonly property color typeColorLight: Qt.lighter(typeColor, 1.10)

    // ── 尺寸 ──
    width: {
        if (round) return computedHeight
        return root.text.length > 0 ? contentRow.implicitWidth + computedPadding * 2 : 80
    }
    implicitWidth: width
    height: computedHeight
    radius: round ? height / 2 : EasyTheme.size.radius

    // ── 背景色 ──
    color: {
        if (!root.enabled || root.loading) return root._bgNormal
        if (mouseArea.containsPress) return root._bgPress
        if (mouseArea.containsMouse) return root._bgHover
        return root._bgNormal
    }
    readonly property color _bgNormal: {
        if (type === "plain") return "transparent"
        if (!primary) return EasyTheme.color.card
        return typeColor
    }
    readonly property color _bgHover: {
        if (type === "plain") return EasyTheme.color.hover
        if (!primary) return EasyTheme.color.buttonHover
        return typeColorLight
    }
    readonly property color _bgPress: {
        if (type === "plain") return EasyTheme.color.buttonHover
        if (!primary) return EasyTheme.color.hover
        return typeColorDark
    }

    opacity: (root.enabled && !root.loading) ? 1.0 : 0.45

    // ── 文字色 ──
    readonly property color textColor: {
        if (primary && !(type === "plain"))
            return "white"
        if (type === "plain")
            return (mouseArea.containsMouse || mouseArea.containsPress) ? typeColor : EasyTheme.color.text
        if (type !== "")
            return typeColor
        return EasyTheme.color.text
    }

    border.color: {
        if (type === "plain") return "transparent"
        if (primary && type === "") return "transparent"
        if (primary) return "transparent"
        if (type !== "") return typeColor
        return EasyTheme.color.border
    }
    border.width: (primary || !root.enabled) ? 0 : EasyTheme.size.borderWidth

    Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }
    Behavior on opacity { NumberAnimation { duration: EasyTheme.transition.fast } }

    // ── Focus ring ──
    Rectangle {
        anchors.fill: parent
        anchors.margins: -3
        radius: root.radius + 3
        color: "transparent"
        border.color: type !== "" ? typeColor : EasyTheme.color.primary
        border.width: _keyProxy.activeFocus ? 2 : 0
        opacity: _keyProxy.activeFocus ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: EasyTheme.transition.fast } }
        z: -1
    }

    // ── Keyboard ──
    Item {
        id: _keyProxy
        anchors.fill: parent
        activeFocusOnTab: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                event.accepted = true
                root.clicked()
            }
        }
    }

    // ── 内容 ──
    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: root.icon !== "" && root.text !== "" ? 6 : 0

        // Loading 旋转
        Item {
            visible: root.loading
            width: root.computedFontSize + 2
            height: width
            anchors.verticalCenter: parent.verticalCenter

            RotationAnimation on rotation {
                from: 0; to: 360
                duration: 900
                loops: Animation.Infinite
                running: root.loading
            }

            Text {
                anchors.centerIn: parent
                text: "⟳"
                font.pixelSize: root.computedFontSize + 2
                color: root.textColor
            }
        }

        // Icon
        EasyIconFont {
            visible: root.icon !== "" && !root.loading
            icon: root.icon
            iconSize: root.computedFontSize + 1
            color: root.textColor
            anchors.verticalCenter: parent.verticalCenter
        }

        // Text
        Text {
            visible: root.text !== "" && !root.round
            text: root.text
            font.pixelSize: root.computedFontSize
            font.family: EasyTheme.font.family
            font.bold: root.primary && root.type === ""
            color: root.textColor
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: EasyTheme.transition.fast } }
        }
    }

    // ── Ripple ──
    Canvas {
        id: rippleCanvas
        anchors.fill: parent
        opacity: 0
        visible: opacity > 0 && root.enabled

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var r = root.radius
            var w = width
            var h = height
            ctx.beginPath()
            ctx.moveTo(r, 0)
            ctx.lineTo(w - r, 0)
            ctx.arcTo(w, 0, w, r, r)
            ctx.lineTo(w, h - r)
            ctx.arcTo(w, h, w - r, h, r)
            ctx.lineTo(r, h)
            ctx.arcTo(0, h, 0, h - r, r)
            ctx.lineTo(0, r)
            ctx.arcTo(0, 0, r, 0, r)
            ctx.closePath()
            ctx.clip()
            ctx.fillStyle = root.primary && root.type === "" ? "rgba(255,255,255,0.25)" : "rgba(0,0,0,0.10)"
            ctx.beginPath()
            ctx.arc(rippleCenter.x, rippleCenter.y, rippleRadius, 0, 2 * Math.PI)
            ctx.fill()
        }
    }

    property real rippleRadius: 0
    property point rippleCenter: Qt.point(0, 0)

    function startRipple(mx, my) {
        rippleCenter = Qt.point(mx, my)
        rippleAnim.stop()
        rippleRadius = 0
        rippleCanvas.opacity = 1
        rippleCanvas.requestPaint()
        rippleAnim.start()
    }

    SequentialAnimation {
        id: rippleAnim
        NumberAnimation {
            target: root; property: "rippleRadius"
            from: 0; to: Math.max(root.width, root.height) * 2.5
            duration: 400; easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: rippleCanvas; property: "opacity"
            from: 1; to: 0
            duration: 200; easing.type: Easing.OutCubic
        }
    }

    onRippleRadiusChanged: rippleCanvas.requestPaint()

    scale: mouseArea.containsPress ? 0.96 : 1.0
    Behavior on scale { NumberAnimation { duration: EasyTheme.transition.instant } }

    // ── Mouse ──
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.enabled && !root.loading
        cursorShape: (root.enabled && !root.loading) ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        enabled: root.enabled && !root.loading
        z: 10
        onPressed: mouse => {
            if (root.enabled && !root.loading)
                startRipple(mouse.x, mouse.y)
        }
        onClicked: {
            if (root.enabled && !root.loading)
                root.clicked()
        }
    }

    // ── Tooltip ──
    Timer {
        id: toolTipTimer
        interval: 500
        onTriggered: {
            if (mouseArea.containsMouse && root.toolTipText !== "") {
                toolTip.text = root.toolTipText
                toolTip.open()
            }
        }
    }

    ToolTip {
        id: toolTip
        delay: 0
        contentItem: Text {
            text: toolTip.text
            font.pixelSize: 12
            color: "#ffffff"
        }
        background: Rectangle {
            color: "#2d2d2d"
            radius: 6
            border.width: 1
            border.color: "#4a4a4a"
        }
    }

    Connections {
        target: mouseArea
        function onContainsMouseChanged() {
            if (mouseArea.containsMouse && root.toolTipText !== "")
                toolTipTimer.start()
            else {
                toolTipTimer.stop()
                toolTip.close()
            }
        }
    }

    signal clicked()
}
