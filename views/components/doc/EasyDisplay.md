# EasyBadge / EasyTag / EasyAvatar / EasyProgress / EasyLoading / EasySkeleton / EasyEmpty / EasyTimeline

## EasyBadge

徽标组件，用于显示数字或状态标记。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `text` | string | "" | 显示文字 |
| `dot` | bool | false | 是否显示为圆点 |
| `type` | string | "default" | 类型：default / success / warning / error |
| `size` | int | sizeNormal | 尺寸 |

## EasyTag

标签组件，支持可关闭和多种类型。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `text` | string | "" | 标签文字 |
| `closable` | bool | false | 是否可关闭 |
| `type` | string | "default" | 类型 |
| `size` | int | sizeNormal | 尺寸 |

## EasyAvatar

头像组件，支持文字头像和圆形/方形。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `text` | string | "" | 显示文字（取首字） |
| `size` | int | 40 | 尺寸 |
| `shape` | string | "circle" | 形状：circle / square |
| `borderWidth` | int | 0 | 边框宽度 |

## EasyProgress

进度条组件。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `value` | real | 0 | 当前值 (0-100) |
| `showText` | bool | false | 是否显示百分比文字 |
| `width` | int | 200 | 宽度 |

## EasyLoading

加载状态组件。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `spinning` | bool | true | 是否旋转 |
| `size` | int | 36 | 尺寸 |
| `text` | string | "" | 加载文字 |

## EasySkeleton

骨架屏加载占位组件，带 shimmer 动画。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `rows` | int | 4 | 骨架行数 |
| `rowHeight` | int | 16 | 每行高度 |
| `spacing` | int | 12 | 行间距 |
| `lastWidth` | real | 0.6 | 最后一行宽度比例 (0~1) |

### 用法

```qml
EasySkeleton { rows: 4 }
EasySkeleton { rows: 3; rowHeight: 20; spacing: 16 }
```

## EasyEmpty

空状态占位组件。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `icon` | string | EasyIcon.material.inbox | 图标 |
| `title` | string | "" | 标题文字 |
| `description` | string | "" | 描述文字 |
| `iconSize` | int | 64 | 图标大小 |

### 用法

```qml
EasyEmpty { title: "暂无数据"; description: "请稍后再试" }
EasyEmpty { icon: EasyIcon.material.search_off; title: "未找到结果" }
```

## EasyTimeline

时间线组件。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `items` | list | [] | 时间线数据 `{title, time, description, color}` |
| `dotSize` | int | 12 | 节点圆点大小 |
| `lineWidth` | int | 2 | 连线宽度 |

### 用法

```qml
EasyTimeline {
    items: [
        { "title": "开始", "time": "2024-01", "description": "项目启动", "color": "#409eff" },
        { "title": "结束", "time": "2024-06", "description": "项目交付", "color": "#67c23a" }
    ]
}
```
