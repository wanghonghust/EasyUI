# EasyColorPicker — 颜色选择器

支持颜色选择、透明度调节、预设颜色和可清除的颜色选择器组件。

## 基础用法

```qml
EasyColorPicker {
    currentColor: "#FF6366f1"
    onColorSelected: function(color) {
        console.log("选择颜色:", color)
    }
}
```

## 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `currentColor` | color | "#FF6366f1" | 当前颜色 |
| `size` | int | EasyTheme.size.sizeNormal | 尺寸（Mini/Small/Normal/Large） |
| `clearable` | bool | false | 是否可清除 |
| `enabled` | bool | true | 是否可用 |

## 信号

- `colorSelected(color color)` — 颜色选择确认时触发

## 示例

### 不同尺寸

```qml
EasyColorPicker { size: EasyTheme.size.sizeMini; currentColor: "#FF4f6ef7" }
EasyColorPicker { size: EasyTheme.size.sizeSmall; currentColor: "#FF22c55e" }
EasyColorPicker { currentColor: "#FFf59e0b" }
EasyColorPicker { size: EasyTheme.size.sizeLarge; currentColor: "#FFef4444" }
```

### 可清除

```qml
EasyColorPicker { currentColor: "#FF6366f1"; clearable: true }
```

### 禁用状态

```qml
EasyColorPicker { currentColor: "#FF4f6ef7"; enabled: false }
```

## 样式说明

- 弹出面板包含色相条、饱和度/亮度选择区、透明度滑块和预设颜色
- 预设颜色提供常用色板快速选择
- 支持透明度（Alpha）调节
- 弹出面板自动判断向上/向下弹出方向