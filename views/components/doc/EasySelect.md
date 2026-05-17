# EasySelect / TimePicker / EasyDatePicker

## EasySelect

下拉选择器组件。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `options` | array | [] | 选项数组 |
| `currentIndex` | int | -1 | 当前选中索引 |
| `size` | int | sizeNormal | 尺寸 |

### 用法

```qml
EasySelect {
    options: ["选项1", "选项2", "选项3"]
    currentIndex: 0
}
```

## TimePicker

时间选择器，支持时/分/秒。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `hour` | int | 0 | 小时 |
| `minute` | int | 0 | 分钟 |
| `second` | int | 0 | 秒 |
| `showSeconds` | bool | true | 是否显示秒 |

## EasyDatePicker

日期选择器。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `date` | date | new Date() | 当前日期 |
| `format` | string | "yyyy-MM-dd" | 显示格式 |
