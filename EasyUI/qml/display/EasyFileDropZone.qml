import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs
import EasyUI

Rectangle {
    id: root

    property alias text: statusText.text
    property bool isDragOver: false
    property bool enabled: true
    property string acceptText: "拖拽文件到此处，或点击选择"
    property string dragOverText: "释放以添加文件"
    property real borderWidth: 2
    property var allowedExtensions: ["*"]

    signal filesDropped(var filePaths)

    implicitWidth: 300; implicitHeight: 160
    radius: EasyTheme.size.radiusLarge
    color: isDragOver ? Qt.rgba(
        EasyTheme.color.primary.r, EasyTheme.color.primary.g,
        EasyTheme.color.primary.b, 0.08) : EasyTheme.color.card
    border.color: isDragOver ? EasyTheme.color.primary : EasyTheme.color.border
    border.width: isDragOver ? borderWidth + 1 : borderWidth

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    ColumnLayout {
        anchors.centerIn: parent; spacing: 12

        Rectangle {
            Layout.preferredWidth: 48; Layout.preferredHeight: 48; radius: 24
            color: isDragOver ? EasyTheme.color.primary : EasyTheme.color.buttonHover
            Layout.alignment: Qt.AlignHCenter

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent; text: "📁"; font.pixelSize: 24
            }
        }

        Text {
            id: statusText
            text: isDragOver ? root.dragOverText : root.acceptText
            font.pixelSize: 13; color: isDragOver ? EasyTheme.color.primary : EasyTheme.color.secondary
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true

            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        acceptedButtons: Qt.LeftButton
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        onClicked: fileDialog.open()
    }

    DropArea {
        anchors.fill: parent
        enabled: root.enabled
        onEntered: function(drag) { root.isDragOver = true; drag.accept() }
        onExited: { root.isDragOver = false }
        onDropped: function(drop) {
            root.isDragOver = false
            var paths = []
            for (var i = 0; i < drop.urls.length; i++) {
                var path = String(drop.urls[i]).replace(/^file:\/\/\//, "")
                if (Qt.platform.os === "windows") path = path.replace(/^\//, "")
                path = decodeURIComponent(path)
                paths.push(path)
            }
            if (paths.length > 0) root.filesDropped(paths)
        }
    }

    FileDialog {
        id: fileDialog
        title: "选择文件"
        fileMode: FileDialog.OpenFiles
        nameFilters: root.allowedExtensions[0] === "*" ? ["所有文件 (*.*)"] : ["支持的文件 (*." + root.allowedExtensions.join(" *.") + ")"]
        onAccepted: {
            if (selectedFiles && selectedFiles.length > 0) {
                var paths = []
                for (var i = 0; i < selectedFiles.length; i++) paths.push(String(selectedFiles[i]))
                root.filesDropped(paths)
            }
        }
    }
}
