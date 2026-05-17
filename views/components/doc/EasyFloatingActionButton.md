# EasyFloatingActionButton (FAB)

悬浮操作按钮，常用于页面主要操作入口。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `icon` | string | "+" | 按钮图标/文字 |
| `iconSize` | real | 24 | 图标大小 |
| `bgColor` | color | theme.primary | 背景色 |
| `elevation` | real | 6 | 阴影高度 |
| `mini` | bool | false | 是否小尺寸 |

### 信号

| 信号 | 说明 |
|------|------|
| `clicked()` | 点击时触发 |

### 用法

```qml
EasyFloatingActionButton {
    icon: "+"
    onClicked: console.log("FAB clicked")
}
```
