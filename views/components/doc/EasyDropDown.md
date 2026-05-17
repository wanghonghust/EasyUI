# EasyDropDown

下拉菜单组件。点击或悬浮触发，展示操作菜单。

## 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| model | list | `[]` | 菜单项数组 |
| trigger | string | `"click"` | 触发方式：`"click"` / `"hover"` |
| placement | string | `"bottom-start"` | 弹出位置：`"bottom-start"` / `"bottom"` / `"bottom-end"` |
| size | int | `EasyTheme.size.sizeNormal` | 尺寸 |
| minWidth | real | 140 | 最小宽度 |
| maxHeight | real | 300 | 最大高度 |
| disabled | bool | false | 是否禁用 |

## Model 字段

| 字段 | 类型 | 说明 |
|------|------|------|
| text | string | 菜单项文字 |
| icon | string | 图标（Material Symbol PUA 字符） |
| disabled | bool | 是否禁用该项 |
| divider | bool | 是否为分割线 |
| visible | bool | 是否可见（默认 true） |
| onClick | function | 点击回调 |

## 默认属性

子元素直接放入，作为触发区域的显示内容。

## 示例

```qml
EasyDropDown {
    width: 120
    model: [
        { text: "编辑", icon: EasyIcon.material.edit, onClick: () => console.log("edit") },
        { text: "复制", icon: EasyIcon.material.content_copy, onClick: () => console.log("copy") },
        { text: "", divider: true },
        { text: "删除", icon: EasyIcon.material.delete, onClick: () => console.log("delete") }
    ]

    EasyButton {
        anchors.fill: parent
        text: "操作"
    }
    EasyIconFont {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        icon: EasyIcon.material.arrow_drop_down
        iconSize: 20
        color: EasyTheme.color.placeholder
    }
}
```
