import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Effects
import EasyUI 1.0

Item {
    id: root

    z: 9999
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    // ======== Positioning ========
    property int maxWidth: 420
    property int gap: 10
    property int margin: 30
    property int topMargin: 30
    property int bottomMargin: 30

    function columnWidth() {
        return Math.min(parent ? parent.width : 0, root.maxWidth)
    }

    // ======== Per-position columns ========
    Item {
        id: container
        anchors.fill: parent

        // — Top row —
        Column {
            id: col_tl
            x: root.margin
            y: root.topMargin
            width: root.columnWidth()
            spacing: root.gap
        }
        Column {
            id: col_tc
            x: (parent.width - width) / 2
            y: root.topMargin
            width: root.columnWidth()
            spacing: root.gap
        }
        Column {
            id: col_tr
            x: parent.width - width - root.margin
            y: root.topMargin
            width: root.columnWidth()
            spacing: root.gap
        }

        // — Bottom row —
        Column {
            id: col_bl
            x: root.margin
            y: parent.height - root.bottomMargin - implicitHeight
            width: root.columnWidth()
            spacing: root.gap
        }
        Column {
            id: col_bc
            x: (parent.width - width) / 2
            y: parent.height - root.bottomMargin - implicitHeight
            width: root.columnWidth()
            spacing: root.gap
        }
        Column {
            id: col_br
            x: parent.width - width - root.margin
            y: parent.height - root.bottomMargin - implicitHeight
            width: root.columnWidth()
            spacing: root.gap
        }
    }

    function columnFor(pos) {
        switch (pos) {
        case "top-left":
            return col_tl
        case "top-right":
            return col_tr
        case "bottom-left":
            return col_bl
        case "bottom-center":
            return col_bc
        case "bottom-right":
            return col_br
        default:
            return col_tc
        }
    }

    function allColumns() {
        return [col_tl, col_tc, col_tr, col_bl, col_bc, col_br]
    }

    // ======== Sync with ToastManager ========
    Connections {
        target: ToastManager
        function onToastsChanged() {
            syncToasts()
        }
    }

    Component.onCompleted: {
        root.parent = Overlay.overlay
        syncToasts()
    }

    function syncToasts() {
        var cppToasts = ToastManager.toasts

        // Build set of C++ ids
        var cppIds = {}
        for (var j = 0; j < cppToasts.length; j++) {
            cppIds[cppToasts[j].id] = true
        }

        // Build set of visual ids (across all position columns)
        var visualById = {}
        var cols = allColumns()
        for (var c = 0; c < cols.length; c++) {
            for (var i = 0; i < cols[c].children.length; i++) {
                var child = cols[c].children[i]
                if (child.toastId !== undefined) {
                    visualById[child.toastId] = child
                }
            }
        }

        // Create new visual items (in C++ but not in visual)
        for (var k = 0; k < cppToasts.length; k++) {
            var cppToast = cppToasts[k]
            if (!visualById[cppToast.id]) {
                var pos = cppToast.position || "top-center"
                var targetCol = columnFor(pos)
                toastComponent.createObject(targetCol, {
                                                "toastId": cppToast.id,
                                                "toastMessage": cppToast.message,
                                                "toastType": cppToast.type,
                                                "toastDuration": cppToast.duration,
                                                "toastPosition": pos,
                                                "toastShowClose": cppToast.showCloseButton !== undefined ? cppToast.showCloseButton : true
                                            })
            }
        }

        // Dismiss visual items not in C++ (were removed)
        for (var id in visualById) {
            var item = visualById[id]
            if (!cppIds[id] && !item.isDismissing) {
                item.dismiss()
            }
        }
    }

    // ======== Type helpers ========
    function typeColor(type) {
        switch (type) {
        case "success":
            return EasyTheme.color.success
        case "warning":
            return EasyTheme.color.warning
        case "error":
            return EasyTheme.color.colorError
        default:
            return EasyTheme.color.info
        }
    }

    function typeIcon(type) {
        switch (type) {
        case "success":
            return EasyIcon.material.check_circle
        case "warning":
            return EasyIcon.material.warning
        case "error":
            return EasyIcon.material.error
        default:
            return EasyIcon.material.info
        }
    }

    // ======== Toast item template ========
    Component {
        id: toastComponent

        Rectangle {
            id: item

            property int toastId: 0
            property string toastMessage: ""
            property string toastType: "info"
            property int toastDuration: 3000
            property string toastPosition: "top-center"
            property bool toastShowClose: true
            property bool isDismissing: false

            width: parent ? parent.width : 420
            implicitHeight: contentLayout.implicitHeight + 28
            radius: EasyTheme.size.radius

            // Solid card background + type-tinted overlay
            color: EasyTheme.color.card

            // Type-color tint overlay
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: {
                    var tc = typeColor(item.toastType)
                    return EasyTheme.isDark
                        ? Qt.rgba(tc.r, tc.g, tc.b, 0.12)
                        : Qt.rgba(tc.r, tc.g, tc.b, 0.06)
                }
            }

            border.color: EasyTheme.color.border
            border.width: EasyTheme.size.borderWidth

            // — Hover pause —
            property bool hovered: false
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: item.hovered = true
                onExited: item.hovered = false
            }

            // — Shadow (via layer) —
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: EasyTheme.color.shadow
                shadowOpacity: EasyTheme.isDark ? 0.20 : 0.06
                shadowBlur: 0.4
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 2
            }

            // — Entry animation —
            opacity: 0
            transform: Translate {
                id: slide
                x: item.toastPosition.endsWith(
                       "-left") ? -20 : item.toastPosition.endsWith(
                                      "-right") ? 20 : 0
                y: !item.toastPosition.endsWith(
                       "center") ? 0 : item.toastPosition.startsWith(
                                       "bottom") ? 20 : -20
            }

            Component.onCompleted: enterAnim.start()

            ParallelAnimation {
                id: enterAnim
                NumberAnimation {
                    target: item
                    property: "opacity"
                    to: 1
                    duration: 200
                }
                NumberAnimation {
                    target: slide
                    property: "y"
                    to: 0
                    duration: 250
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: slide
                    property: "x"
                    to: 0
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            // — Exit animation —
            NumberAnimation {
                id: exitAnim
                target: item
                property: "opacity"
                to: 0
                duration: 200
                onFinished: {
                    ToastManager.removeById(item.toastId)
                    item.destroy()
                }
            }

            function dismiss() {
                isDismissing = true
                dismissTimer.stop()
                exitAnim.start()
            }

            // — Auto-dismiss timer —
            Timer {
                id: dismissTimer
                interval: item.toastDuration
                running: item.toastDuration > 0 && item.opacity > 0
                         && !item.hovered
                onTriggered: item.dismiss()
            }

            // — Content —
            RowLayout {
                id: contentLayout
                anchors {
                    left: parent.left
                    leftMargin: 20
                    right: parent.right
                    rightMargin: 16
                    top: parent.top
                    topMargin: 14
                    bottom: parent.bottom
                    bottomMargin: 14
                }
                spacing: 12

                EasyIconFont {
                    icon: typeIcon(item.toastType)
                    iconSize: 22
                    color: typeColor(item.toastType)
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: 1
                }

                Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: item.toastMessage
                    font.pixelSize: EasyTheme.font.sizeNormal
                    color: EasyTheme.color.text
                    wrapMode: Text.Wrap
                    lineHeight: 1.4
                }

                // — Close button with hover circle —
                Item {
                    visible: item.toastShowClose
                    width: 24
                    height: 24
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: 0

                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: closeArea.containsMouse ? (EasyTheme.isDark ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.06)) : "transparent"
                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }
                    }

                    EasyIconFont {
                        anchors.centerIn: parent
                        icon: EasyIcon.material.close
                        iconSize: 16
                        color: EasyTheme.color.secondary
                    }

                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        anchors.margins: -6
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: item.dismiss()
                    }
                }
            }
        }
    }
}
