# EasyCommandPalette

命令面板弹窗，支持模糊搜索和键盘导航。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `commands` | array | [] | 命令列表 `[{id, title, subtitle, icon?, shortcut?, category?, keywords?, data?}]` |
| `placeholderText` | string | "搜索命令..." | 搜索框占位文字 |

### 信号

| 信号 | 说明 |
|------|------|
| `commandSelected(id, data)` | 选中命令时触发 |

### 用法

```qml
EasyCommandPalette {
    id: palette
    commands: [
        { id: "home", title: "首页", subtitle: "返回首页", icon: "🏠", shortcut: "Ctrl+H" },
        { id: "search", title: "搜索", subtitle: "搜索内容", icon: "🔍", shortcut: "Ctrl+F" }
    ]
    onCommandSelected: function(id, data) {
        console.log("Selected:", id)
    }
}

EasyButton {
    text: "打开"
    onClicked: palette.open()
}
```
