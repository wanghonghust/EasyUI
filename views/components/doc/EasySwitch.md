# EasySwitch / EasyCheckbox / EasyRadio / EasyToggle

## EasySwitch

滑动开关组件。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `checked` | bool | false | 是否选中 |
| `size` | int | sizeNormal | 尺寸 |

### 信号

- `toggled(bool checked)` — 状态切换时触发

## EasyCheckbox

复选框组件。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `text` | string | "" | 标签文字 |
| `checked` | bool | false | 是否选中 |
| `size` | int | sizeNormal | 尺寸 |

## EasyRadio

单选框组件。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `text` | string | "" | 标签文字 |
| `checked` | bool | false | 是否选中 |
| `size` | int | sizeNormal | 尺寸 |

## EasyToggle

切换按钮组件，类似 Checkbox 但样式为按钮。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `text` | string | "" | 按钮文字 |
| `checked` | bool | false | 是否选中 |
| `size` | int | sizeNormal | 尺寸 |

### 信号

- `toggled(bool checked)` — 状态切换时触发
