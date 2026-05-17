# EasyButton / EasyButtonGroup

## EasyButton

按钮组件，支持多种尺寸、类型和状态。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `text` | string | "" | 按钮文字 |
| `primary` | bool | false | 是否为主按钮 |
| `size` | int | sizeNormal | 尺寸：sizeMini / sizeSmall / sizeNormal / sizeLarge |
| `enabled` | bool | true | 是否可用 |

### 用法

```qml
EasyButton { text: "主按钮"; primary: true }
EasyButton { text: "次要按钮"; primary: false }
EasyButton { text: "禁用"; enabled: false }
```

## EasyButtonGroup

按钮组组件，支持单选和多选模式。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `buttons` | array | [] | 按钮文字数组 |
| `exclusive` | bool | true | 是否为单选模式 |
| `currentIndex` | int | -1 | 当前选中索引（单选） |
| `currentIndices` | array | [] | 当前选中索引数组（多选） |

### 用法

```qml
// 单选
EasyButtonGroup {
    buttons: ["日", "周", "月", "年"]
    currentIndex: 0
}

// 多选
EasyButtonGroup {
    buttons: ["加粗", "斜体", "下划线"]
    exclusive: false
    currentIndices: [0, 2]
}
```
