# EasyScrollBar — VS Code 极简滚动条

极简风格滚动条组件，模仿 VS Code 的滚动条设计。

## 基础用法

```qml
ScrollView {
    ScrollBar.vertical: EasyScrollBar { }
    // Your content here
}
```

## 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| expandOnHover | bool | true | hover 时是否展开（6px→10px） |
| normalSize | int | 6 | 默认滑块宽度 |
| hoverSize | int | 10 | hover 时滑块宽度 |

## 示例

### 垂直滚动

```qml
Rectangle {
    width: 300; height: 200
    ScrollView {
        anchors.fill: parent
        anchors.margins: 12
        clip: true
        ScrollBar.vertical: EasyScrollBar { }
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        Text {
            width: parent.width
            text: "长文本内容..."
        }
    }
}
```

### 水平滚动

```qml
ScrollView {
    ScrollBar.horizontal: EasyScrollBar { }
    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
    Row {
        // 宽内容...
    }
}
```

### 双向滚动

```qml
ScrollView {
    ScrollBar.vertical: EasyScrollBar { }
    ScrollBar.horizontal: EasyScrollBar { }
    // 超出宽高的内容
}
```

### 禁用展开

```qml
EasyScrollBar {
    expandOnHover: false
}
```

## 样式说明

- 滑块默认 6px 宽，hover 自动扩展到 10px
- 半透明灰色滑块（亮色模式 16%，暗色模式 30%）
- hover 和 press 时滑块逐渐变深
- 无轨道背景，极简视觉
- 120ms 平滑展开过渡动画
