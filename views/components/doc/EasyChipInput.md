# EasyChipInput

标签输入组件，支持添加和删除标签。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `chips` | array | [] | 标签数组 `[{text, color?}]` |
| `placeholder` | string | "输入后按 Enter 添加" | 输入框占位文字 |
| `maxChips` | int | 20 | 最大标签数 |
| `allowDuplicates` | bool | false | 是否允许重复标签 |
| `readOnly` | bool | false | 是否只读 |

### 信号

| 信号 | 说明 |
|------|------|
| `chipAdded(text)` | 添加标签时触发 |
| `chipRemoved(index, text)` | 删除标签时触发 |
| `chipsUpdated(chips)` | 标签数组变更时触发 |

### 用法

```qml
EasyChipInput {
    placeholder: "输入后按 Enter"
    chips: [
        { text: "Qt Quick", color: "#6366f1" },
        { text: "C++", color: "#f59e0b" }
    ]
    onChipAdded: function(text) { console.log("Added:", text) }
}
```
