# EasyMenuBar / EasyMenuButton

## EasyMenuBar

侧边菜单栏组件，支持展开/折叠、多级嵌套和弹出菜单。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `menus` | array | [] | 菜单项数组 `{title, icon, url, children}` |
| `activePath` | string | "" | 当前激活路径 |
| `collapsed` | bool | false | 是否折叠 |
| `expandAll` | bool | false | 是否全部展开 |
| `hoverExpand` | bool | false | 悬停时自动展开 |

### 信号

- `itemClicked(var item)` — 菜单项点击
- `collapseChanged(bool collapsed)` — 折叠状态变化

### 用法

```qml
EasyMenuBar {
    menus: [
        { "title": "首页", "icon": "\ue88a", "url": "home", "children": [] },
        { "title": "设置", "icon": "\ue8b8", "url": "theme", "children": [
            { "title": "主题", "icon": "", "url": "theme", "children": [] }
        ]}
    ]
    activePath: "home"
}
```

## EasyMenuButton

菜单栏中的按钮项。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `title` | string | "" | 按钮文字 |
| `icon` | string | "" | 字体图标 Unicode |
| `iconTail` | url | "" | 尾部图标（箭头） |
| `active` | bool | false | 是否激活 |
| `extraLeftPadding` | int | 0 | 额外左侧内边距 |
