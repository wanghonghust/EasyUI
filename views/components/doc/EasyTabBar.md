# EasyTabBar

Edge 浏览器风格的标签页组件，选中标签带有阴影和悬浮效果。

## 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| tabs | list | [] | 标签页数组，每项为 `{title, icon, closable}` |
| currentIndex | int | 0 | 当前选中标签索引 |
| addable | bool | true | 是否显示添加按钮 |
| size | int | sizeNormal | 尺寸：sizeMini / sizeSmall / sizeNormal / sizeLarge |

## 信号

| 信号 | 参数 | 说明 |
|------|------|------|
| tabClicked | int index | 标签点击 |
| tabClosed | int index | 标签关闭 |
| addClicked | - | 添加按钮点击 |

## 用法

```qml
EasyTabBar {
    tabs: [
        { "title": "首页", "icon": EasyIcon.material.home, "closable": false },
        { "title": "文档", "icon": EasyIcon.material.description, "closable": true }
    ]
    onTabClosed: (index) => {
        var newTabs = tabs.slice()
        newTabs.splice(index, 1)
        tabs = newTabs
    }
    onAddClicked: {
        tabs = tabs.concat({ "title": "新标签", "closable": true })
    }
}
```

> 图标使用 `EasyIcon.material.xxx` 传入，不需要手动填写 Unicode 字符。
