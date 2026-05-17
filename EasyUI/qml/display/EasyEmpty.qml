import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI 1.0

/**
 * EasyEmpty —— 空状态占位组件
 *
 * 属性：
 *   icon        {string}    图标（EasyIcon.material），默认 EasyIcon.material.inbox
 *   title       {string}    标题文字
 *   description {string}    描述文字
 *   iconSize    {int}       图标大小，默认 64
 *
 * 用法：
 *   EasyEmpty {
 *       title: "暂无数据"
 *       description: "请稍后再试"
 *   }
 *   EasyEmpty {
 *       icon: EasyIcon.material.search_off
 *       title: "未找到结果"
 *       description: "请尝试修改搜索关键词"
 *   }
 */
Item {
    id: root

    property string icon: EasyIcon.material.inbox
    property string title: ""
    property string description: ""
    property int iconSize: 64

    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight

    Column {
        id: column
        anchors.centerIn: parent
        topPadding: 24
        bottomPadding: 24
        spacing: 16

        EasyIconFont {
            anchors.horizontalCenter: parent.horizontalCenter
            icon: root.icon
            iconSize: root.iconSize
            color: EasyTheme.color.placeholder
            opacity: 0.6
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.title
            font.pixelSize: 15
            font.bold: true
            color: EasyTheme.color.text
            visible: root.title !== ""
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.description
            font.pixelSize: 12
            color: EasyTheme.color.placeholder
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            width: Math.min(implicitWidth, 250)
            visible: root.description !== ""
        }
    }
}
