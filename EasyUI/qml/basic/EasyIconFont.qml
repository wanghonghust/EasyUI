/**
 * EasyIconFont —— 图标字体组件
 *
 * 使用 Material Symbols Outlined 字体。
 *
 * 属性：
 *   icon     {string}  图标 Unicode 字符
 *   iconSize {int}     图标尺寸，默认 24
 *   color    {color}   图标颜色，默认跟随主题文字色
 *
 * 使用示例：
 *   EasyIconFont { icon: EasyIcon.material.home; iconSize: 24 }
 */
import QtQuick
import EasyUI

Text {
    id: root

    property string icon: ""
    property int iconSize: 24

    text: icon
    font.pixelSize: iconSize
    color: EasyTheme.color.text
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering

    font.family: "Material Symbols Outlined"

    FontLoader {
        source: Qt.resolvedUrl("../../res/fonts/MaterialSymbolsOutlined.ttf")
    }
}
