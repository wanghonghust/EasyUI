# EasyFileDropZone

文件拖放区域，支持拖拽文件和点击选择。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `acceptText` | string | "拖拽文件到此处..." | 默认提示文字 |
| `dragOverText` | string | "释放以添加文件" | 拖拽悬停提示 |
| `enabled` | bool | true | 是否可用 |
| `allowedExtensions` | array | ["*"] | 允许的文件扩展名 |

### 信号

| 信号 | 说明 |
|------|------|
| `filesDropped(filePaths)` | 文件投放时触发 |

### 用法

```qml
EasyFileDropZone {
    implicitHeight: 200
    allowedExtensions: ["png", "jpg", "gif"]
    onFilesDropped: function(paths) {
        console.log("Files:", paths.join(", "))
    }
}
```
