# EasyWatermark

水印叠加组件，在内容上方显示半透明重复文字。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `text` | string | "机密" | 水印文字 |
| `watermarkOpacity` | real | 0.08 | 水印透明度 |
| `fontSize` | real | 14 | 文字大小 |
| `textColor` | color | theme.text | 文字颜色 |
| `spacing` | real | 120 | 水印间距 |
| `rotationAngle` | real | -20 | 旋转角度 |

### 用法

```qml
Rectangle {
    EasyWatermark {
        text: "机密文档"
        watermarkOpacity: 0.06
        rotationAngle: -25
    }
    Text { text: "受保护的内容" }
}
```
