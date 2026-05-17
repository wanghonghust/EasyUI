# EasyImageViewer

图片查看器，支持缩放、拖拽和旋转。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `source` | url | "" | 图片路径 |
| `imgScale` | real | 1.0 | 当前缩放比例 |
| `minScale` | real | 0.1 | 最小缩放比例 |
| `maxScale` | real | 10.0 | 最大缩放比例 |
| `rotationAngle` | real | 0 | 旋转角度 |

### 用法

```qml
EasyImageViewer {
    id: viewer
    source: "qrc:/path/to/image.png"
}

EasyButton {
    text: "查看图片"
    onClicked: viewer.open()
}
```

支持操作：滚轮缩放、拖拽平移、双指捏合、工具栏按钮（放大/缩小/旋转/重置/关闭）。
