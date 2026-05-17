import QtQuick
import QtQuick.Controls.Basic
import EasyUI

Rectangle {
    id: root

    property string text: "机密"
    property real watermarkOpacity: 0.08
    property real fontSize: 14
    property color textColor: EasyTheme.color.text
    property real spacing: 140
    property real rotationAngle: -22

    anchors.fill: parent
    color: "transparent"
    clip: true
    radius: 8
    layer.enabled: true
    layer.smooth: true
    z: 9999
    visible: true

    Repeater {
        model: {
            var cols = Math.ceil(root.width / root.spacing) + 1
            var rows = Math.ceil(root.height / root.spacing) + 1
            return cols * rows
        }
        delegate: Text {
            property int col: index % (Math.ceil(root.width / root.spacing) + 1)
            property int row: Math.floor(index / (Math.ceil(root.width / root.spacing) + 1))
            x: col * root.spacing - root.spacing / 2 + (row % 2) * (root.spacing / 2)
            y: row * root.spacing - root.spacing / 2
            text: root.text; font.pixelSize: root.fontSize; color: root.textColor
            opacity: root.watermarkOpacity; rotation: root.rotationAngle
            width: root.spacing; height: root.spacing
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
