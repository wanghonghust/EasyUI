# EasySlider / EasyRate / EasySegmented

## EasySlider

滑块组件。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `value` | real | 0 | 当前值 (0-100) |
| `width` | int | 200 | 宽度 |

## EasyRate

评分组件，支持半星和只读模式。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `value` | real | 0 | 当前评分 |
| `max` | int | 5 | 最大星数 |
| `allowHalf` | bool | false | 允许半星 |
| `readonly` | bool | false | 只读模式 |
| `size` | int | 24 | 星星尺寸 |

## EasySegmented

分段控制器，支持单选和多选。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `options` | array | [] | 选项数组 `{text: ""}` |
| `currentIndex` | int | -1 | 当前选中（单选） |
| `currentIndices` | array | [] | 当前选中（多选） |
| `exclusive` | bool | true | 是否单选 |
| `size` | int | sizeNormal | 尺寸 |
