# EasyCascader 级联选择器

级联选择器，适用于多级层级结构逐级选择。

## 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| model | array | [] | 级联数据 |
| selectedPath | array | [] | 默认选中路径 |
| placeholder | string | "请选择" | 占位文字 |
| enabled | bool | true | 是否可用 |
| size | int | sizeNormal | 控件尺寸 |
| displayField | string | "label" | 显示字段 |
| valueField | string | "value" | 值字段 |
| childrenField | string | "children" | 子级字段 |

## 数据格式

```json
[
  {
    "label": "北京",
    "value": "beijing",
    "children": [
      { "label": "朝阳区", "value": "chaoyang" },
      { "label": "海淀区", "value": "haidian" }
    ]
  }
]
```

## 事件

| 事件 | 说明 |
|------|------|
| pathSelected(path) | 选中路径变化 |

## 使用示例

```qml
EasyCascader {
    model: myData
    placeholder: "请选择地区"
    onPathSelected: function(path) {
        console.log(path)
    }
}
```
