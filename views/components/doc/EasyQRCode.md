# EasyQRCode

二维码生成组件，基于 Canvas 绘制。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `text` | string | "" | 要编码的文本/URL |
| `moduleSize` | int | 6 | 模块像素大小 |
| `foregroundColor` | color | "#000000" | 前景色 |
| `backgroundColor` | color | "#FFFFFF" | 背景色 |
| `errorCorrection` | enum | Medium | 纠错级别：Low / Medium / Quartile / High |

### 用法

```qml
EasyQRCode {
    text: "https://example.com"
    width: 200; height: 200
    moduleSize: 6
}
```
