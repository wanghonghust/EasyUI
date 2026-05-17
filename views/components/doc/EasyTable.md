# EasyTable / EasyPagination / EasyTransfer

## EasyTable

表格组件，支持选择、排序、分页和自定义单元格。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `columns` | array | [] | 列定义 `{title, key, width, align}` |
| `tableData` | array | [] | 数据数组 |
| `selectable` | bool | false | 是否可选择行 |
| `sortable` | bool | false | 是否可排序 |
| `stripe` | bool | true | 是否斑马纹 |
| `hoverHighlight` | bool | true | 是否高亮 hover 行 |
| `rowBorder` | bool | false | 是否显示行边框 |
| `headerColor` | color | primary | 表头背景色 |
| `rowHeight` | int | 36 | 行高 |
| `maxHeight` | int | -1 | 最大高度（-1 不限制） |
| `pagination` | bool | false | 是否分页 |
| `pageSize` | int | 10 | 每页条数 |
| `expandable` | bool | false | 是否支持子项展开 |
| `childrenProperty` | string | "children" | 子项数据属性名 |
| `delegate` | Component | null | 自定义单元格渲染 |

### 信号

- `rowClicked(int index, var rowData)` — 行点击
- `rowDoubleClicked(int index, var rowData)` — 行双击
- `selectionChanged(array indices)` — 选择变化
- `sortChanged(string key, bool ascending)` — 排序变化
- `pageChanged(int page)` — 页码变化

### 属性（只读）

- `selectedRows` — 当前选中的行索引集合

### 方法

- `refresh()` — 刷新表格显示

## EasyPagination

分页器组件。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `currentPage` | int | 1 | 当前页 |
| `totalPage` | int | 1 | 总页数 |
| `pageSize` | int | 10 | 每页条数 |
| `totalCount` | int | 0 | 总条数 |
| `size` | int | sizeNormal | 尺寸 |
| `showFirstLast` | bool | true | 显示首尾页跳转按钮 |
| `showJump` | bool | true | 显示页码跳转输入框 |
| `showPageSizeSelector` | bool | false | 显示每页条数选择器 |
| `pageSizeOptions` | array | [10,20,50,100] | 每页条数可选值 |

### 信号

- `pageChanged(int page)` — 页码变化
- `pageSizeUpdated(int size)` — 每页条数变化

## EasyTransfer

穿梭框组件，用于左右列表数据转移。

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `sourceItems` | array | [] | 左侧源数据 |
| `targetItems` | array | [] | 右侧目标数据 |
| `titleLeft` | string | "" | 左侧标题 |
| `titleRight` | string | "" | 右侧标题 |

### 方法

- `getTargetLabels()` — 获取右侧选中项标签数组
