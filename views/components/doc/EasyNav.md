# EasyBreadcrumb / EasyTabBar / EasyTreeView / EasyCollapse

## EasyBreadcrumb

面包屑导航组件。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `items` | array | [] | 路径项 `{text: ""}` |
| `separator` | string | "/" | 分隔符 |
| `currentIndex` | int | -1 | 当前选中索引 |

### 信号

- `itemClicked(int index)` — 点击路径项

### 用法

```qml
EasyBreadcrumb {
    items: [{ "text": "首页" }, { "text": "组件库" }, { "text": "面包屑" }]
}
```

## EasyTabBar

标签栏组件，支持关闭标签。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `tabs` | array | [] | 标签数组 `{text, closable}` |
| `currentIndex` | int | 0 | 当前选中索引 |

### 信号

- `tabClicked(int index)` — 标签点击
- `tabClosed(int index)` — 标签关闭

## EasyTreeView

树形视图组件，支持多级展开/折叠。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `model` | list | [] | 树形数据 `{label, icon, children}` |
| `indent` | int | 24 | 每层缩进像素 |
| `rowHeight` | int | 32 | 每行高度 |

### 信号

- `nodeClicked(var node)` — 节点点击

### 用法

```qml
EasyTreeView {
    model: [
        { "label": "目录", "icon": EasyIcon.material.folder, "children": [
            { "label": "文件", "icon": EasyIcon.material.description }
        ]}
    ]
    onNodeClicked: (node) => console.log(node.label)
}
```

## EasyCollapse

折叠面板组件。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `title` | string | "" | 面板标题 |
| `isExpanded` | bool | false | 是否展开 |

### 用法

```qml
EasyCollapse {
    title: "标题"
    isExpanded: true
    Text { text: "面板内容" }
}
```
