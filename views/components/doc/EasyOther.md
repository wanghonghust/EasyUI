# EasyDivider / EasyCard / EasyCarousel / EasyLyric / EasyIconFont / EasyMarkdownView

## EasyDivider

分隔线组件。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `orientation` | int | Qt.Horizontal | 方向 |
| `length` | int | 0 | 长度（0 表示自动填充） |

## EasyCard

卡片容器组件。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `padding` | int | 16 | 内边距 |

## EasyCarousel

轮播组件，支持多种指示器和箭头样式。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `items` | array | [] | 轮播项数组 |
| `carouselHeight` | int | 200 | 高度 |
| `autoPlay` | bool | true | 自动播放 |
| `interval` | int | 3000 | 切换间隔(ms) |
| `indicatorStyle` | string | "dots" | 指示器样式：dots / numbers / bars |
| `arrowStyle` | string | "always" | 箭头样式：always / hover / none |
| `delegate` | Component | null | 自定义渲染项 |

## EasyLyric

歌词显示组件，支持 LRC 格式和时间同步高亮。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `lyricText` | string | "" | LRC 格式歌词 |
| `currentTime` | int | 0 | 当前播放时间(ms) |
| `lineHeight` | int | 36 | 行高 |

### 信号

- `jumpToTime(int time)` — 点击歌词跳转

## EasyIconFont

图标字体组件，基于 Material Symbols。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `icon` | string | "" | Unicode 字符，如 `"\ue88a"` |
| `iconSize` | int | 24 | 图标尺寸 |
| `color` | color | EasyTheme.color.text | 图标颜色 |

## EasyMarkdownView

Markdown 渲染视图。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `text` | string | "" | Markdown 内容 |
