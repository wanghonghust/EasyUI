# EasyChart

图表组件，支持折线图、柱状图、饼图和环形图。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `chartType` | enum | Line | 图表类型：Line / Bar / Pie / Donut |
| `dataPoints` | array | [] | 数据点数组 `[{label, value, color?}]` |
| `showGrid` | bool | true | 是否显示网格线 |
| `showLabels` | bool | false | 是否显示数据标签 |
| `showLegend` | bool | false | 是否显示图例 |
| `animated` | bool | true | 是否启用动画 |
| `animationDuration` | int | 600 | 动画时长(ms) |
| `lineWidth` | real | 3 | 折线宽度 |
| `pointRadius` | real | 4 | 数据点半径 |
| `barSpacing` | real | 0.3 | 柱间距比例 |
| `donutHoleRatio` | real | 0.62 | 环形图空心比例 |
| `accentColor` | color | theme.primary | 主色调 |
| `centerText` | string | "" | 环形图中心文字 |
| `centerSubText` | string | "" | 环形图中心副文字 |

### 用法

```qml
// 折线图
EasyChart {
    chartType: EasyChart.ChartType.Line
    dataPoints: [{label:"周一",value:22}, {label:"周二",value:28}]
}

// 柱状图
EasyChart {
    chartType: EasyChart.ChartType.Bar
    dataPoints: [{label:"A",value:45,color:"#6366f1"}]
}

// 饼图
EasyChart {
    chartType: EasyChart.ChartType.Pie
    dataPoints: [{label:"产品",value:35,color:"#6366f1"}]
    showLabels: true
}

// 环形图
EasyChart {
    chartType: EasyChart.ChartType.Donut
    dataPoints: [{label:"完成",value:65,color:"#10b981"}]
    centerText: "65%"; centerSubText: "完成率"
}
```
