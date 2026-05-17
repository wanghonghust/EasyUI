# EasyInput / EasyNumberInput / EasyIPInput / EasyMACInput / EasyTextArea / EasySearchInput

## EasyInput

通用输入框组件，支持多种尺寸和类型。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `placeholder` | string | "" | 占位提示文字 |
| `text` | string | "" | 输入内容 |
| `password` | bool | false | 是否为密码模式 |
| `size` | int | sizeNormal | 尺寸 |
| `width` | int | 200 | 宽度 |

## EasyNumberInput

数字输入框，支持整数和小数。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `value` | real | 0 | 当前值 |
| `min` | real | 0 | 最小值 |
| `max` | real | Infinity | 最大值 |
| `step` | real | 1 | 步进值 |
| `precision` | int | 0 | 小数精度 |

## EasyIPInput

IP 地址输入框，自动分段验证。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `ipAddress` | string | "" | IP 地址 |
| `placeholder` | string | "" | 占位提示 |

## EasyMACInput

MAC 地址输入框，支持自定义分隔符。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `macAddress` | string | "" | MAC 地址 |
| `separator` | string | ":" | 分隔符 |

## EasyTextArea

多行文本输入框。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `text` | string | "" | 内容 |
| `readOnly` | bool | false | 只读 |
| `maxLength` | int | -1 | 最大长度 |
| `showCount` | bool | false | 显示字数统计 |

## EasySearchInput

搜索框组件，带搜索图标。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `placeholder` | string | "" | 占位提示 |
| `onSearch` | signal | - | 搜索信号 |
