import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI

Item {
    id: root

    property int splitterWidth: 4
    property real splitRatio: 0.4
    property var leftContent: null
    property var rightContent: null
    default property alias data: contentArea.data

    implicitWidth: 600; implicitHeight: 400

    RowLayout {
        anchors.fill: parent; spacing: 0

        Item {
            id: leftPane
            Layout.preferredWidth: root.width * root.splitRatio
            Layout.minimumWidth: leftMinWidth
            Layout.fillHeight: true
            clip: true
            property real leftMinWidth: 100

            Loader {
                anchors.fill: parent
                sourceComponent: root.leftContent
            }
        }

        Rectangle {
            id: splitHandle
            Layout.preferredWidth: root.splitterWidth
            Layout.fillHeight: true
            color: handleArea.containsMouse ? EasyTheme.color.primary : EasyTheme.color.border
            Behavior on color { ColorAnimation { duration: 150 } }

            MouseArea {
                id: handleArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.SplitHCursor

                property real startX: 0; property real startW: 0

                onPressed: function(mouse) {
                    startX = mouse.x
                    startW = leftPane.width
                }
                onMouseXChanged: function(mouse) {
                    var dx = mouse.x - startX
                    var newW = Math.max(leftPane.leftMinWidth, startW + dx)
                    newW = Math.min(newW, root.width - 100)
                    root.splitRatio = newW / root.width
                }
            }
        }

        Item {
            id: rightPane
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true

            Loader {
                anchors.fill: parent
                sourceComponent: root.rightContent
            }
        }
    }

    // Sub-items (if using inline declarative children instead of leftContent/rightContent)
    Item { id: contentArea; anchors.fill: parent; visible: false }
}
