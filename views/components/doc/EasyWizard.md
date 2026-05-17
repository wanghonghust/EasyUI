# EasyWizard

步骤向导组件，引导用户完成多步骤操作。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `steps` | array | [] | 步骤数组 `[{title, subtitle, content: Component}]` |
| `currentStep` | int | 0 | 当前步骤索引 |
| `showBackButton` | bool | true | 是否显示返回按钮 |
| `finishText` | string | "完成" | 完成按钮文字 |

### 信号

| 信号 | 说明 |
|------|------|
| `finished()` | 完成所有步骤时触发 |
| `cancelled()` | 取消时触发 |

### 用法

```qml
Component {
    id: step1Content
    Text { text: "步骤1内容" }
}

EasyWizard {
    steps: [
        { title: "第一步", subtitle: "填写信息", content: step1Content },
        { title: "第二步", subtitle: "确认", content: step2Content }
    ]
    onFinished: console.log("完成")
    onCancelled: console.log("取消")
}
```
