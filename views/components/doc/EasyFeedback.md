# EasyAlert / EasyTooltip / EasyDialog / EasyDrawer

## EasyAlert

提示框组件，用于页面内信息提示。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `type` | string | "info" | 类型：info / success / warning / error |
| `title` | string | "" | 标题 |
| `text` | string | "" | 内容 |
| `closable` | bool | true | 是否可关闭 |

## EasyTooltip

工具提示组件，悬停时显示提示文字。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `text` | string | "" | 提示内容 |
| `placement` | string | "top" | 位置：top / bottom / left / right |
| `delay` | int | 500 | 延迟显示时间(ms) |

### 用法

```qml
EasyTooltip {
    text: "提示文字"
    placement: "top"
    EasyButton { text: "悬停查看" }
}
```

## EasyDialog

对话框组件。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `headerTitle` | string | "" | 标题 |
| `confirmText` | string | "确定" | 确认按钮文字 |
| `cancelText` | string | "取消" | 取消按钮文字 |
| `dialogWidth` | int | 400 | 对话框宽度 |

### 方法

- `open()` — 打开对话框
- `close()` — 关闭对话框

## EasyDrawer

抽屉组件，从四边滑出。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `edge` | int | Qt.LeftEdge | 滑出方向 |
| `width` | int | 300 | 宽度（左右时） |
| `height` | int | 300 | 高度（上下时） |

### 方法

- `open()` — 打开抽屉
- `close()` — 关闭抽屉
