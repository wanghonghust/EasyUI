import QtQuick
import QtQuick.Layouts
import EasyUI

Item {
    implicitHeight: contentLayout.implicitHeight + 48

    ColumnLayout {
        id: contentLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 24

        // ========== EasyTable ==========
        Text {
            text: "表格 (EasyTable)"
            font.pixelSize: 16
            font.bold: true
            color: EasyTheme.color.text
        }
        ColumnLayout {
            spacing: 12
            Layout.fillWidth: true

            Text { text: "可选择 + 可排序"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            EasyTable {
                id: sampleTable
                Layout.fillWidth: true
                selectable: true
                sortable: true
                columns: [
                    { "title": "姓名", "key": "name", "width": 120 },
                    { "title": "年龄", "key": "age" },
                    { "title": "邮箱", "key": "email" },
                    { "title": "状态", "key": "status", "width": 100 }
                ]
                tableData: [
                    { "name": "张三", "age": 28, "email": "zhang@example.com", "status": "活跃" },
                    { "name": "李四", "age": 32, "email": "li@example.com", "status": "离线" },
                    { "name": "王五", "age": 25, "email": "wang@example.com", "status": "忙碌" },
                    { "name": "赵六", "age": 29, "email": "zhao@example.com", "status": "活跃" },
                    { "name": "钱七", "age": 35, "email": "qian@example.com", "status": "离线" }
                ]
            }

            Text { text: "只读 + 行边框"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            EasyTable {
                Layout.fillWidth: true
                selectable: false
                sortable: false
                rowBorder: true
                columns: [
                    { "title": "代码", "key": "code", "width": 100 },
                    { "title": "名称", "key": "name" },
                    { "title": "最新价", "key": "price", "align": Text.AlignLeft },
                    { "title": "涨跌幅", "key": "change", "width": 100, "align": Text.AlignLeft }
                ]
                tableData: [
                    { "code": "600519", "name": "贵州茅台", "price": "1688.00", "change": "+1.23%" },
                    { "code": "000858", "name": "五粮液", "price": "142.50", "change": "-0.87%" },
                    { "code": "601318", "name": "中国平安", "price": "48.30", "change": "+0.42%" },
                    { "code": "000001", "name": "平安银行", "price": "11.05", "change": "-1.25%" }
                ]
            }
        }

        Text { text: "可展开表格（子项折叠）"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        EasyTable {
            Layout.fillWidth: true
            expandable: true
            columns: [
                { "title": "部门", "key": "name", "width": 150 },
                { "title": "负责人", "key": "leader", "width": 100 },
                { "title": "人数", "key": "count", "width": 80 },
                { "title": "描述", "key": "desc" }
            ]
            tableData: [
                { "name": "技术部", "leader": "张工", "count": 12, "desc": "负责产品研发与技术维护", "children": [
                    { "name": "前端组", "leader": "李四", "count": 5, "desc": "负责前端开发" },
                    { "name": "后端组", "leader": "王五", "count": 5, "desc": "负责后端服务" },
                    { "name": "测试组", "leader": "赵六", "count": 2, "desc": "负责质量测试" }
                ]},
                { "name": "市场部", "leader": "孙总", "count": 8, "desc": "负责市场推广与品牌", "children": [
                    { "name": "推广组", "leader": "周七", "count": 4, "desc": "线上推广" },
                    { "name": "品牌组", "leader": "吴八", "count": 4, "desc": "品牌管理" }
                ]},
                { "name": "人事部", "leader": "陈总", "count": 5, "desc": "负责人员招聘与培训" }
            ]
        }

        EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

        // ========== EasyPagination ==========
        Text {
            text: "分页器 (EasyPagination)"
            font.pixelSize: 16
            font.bold: true
            color: EasyTheme.color.text
        }
        ColumnLayout {
            spacing: 16
            Layout.fillWidth: true
            Text { text: "不同尺寸"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            EasyPagination { currentPage: 2; totalPage: 8; size: EasyTheme.size.sizeMini }
            EasyPagination { currentPage: 2; totalPage: 8; size: EasyTheme.size.sizeSmall }
            EasyPagination { currentPage: 2; totalPage: 8 }
            EasyPagination { currentPage: 2; totalPage: 8; size: EasyTheme.size.sizeLarge }
            Text { text: "显示总数"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            EasyPagination { currentPage: 1; totalPage: 5; pageSize: 20; totalCount: 100 }
        }

        Text { text: "首尾页跳转 + 页码跳转"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        EasyPagination { currentPage: 3; totalPage: 15; size: EasyTheme.size.sizeSmall }

        Text { text: "可调每页条数（下拉选择）"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        EasyPagination {
            id: sizeSelectorDemo
            currentPage: 1
            totalPage: 10
            pageSize: 20
            size: EasyTheme.size.sizeSmall
            showPageSizeSelector: true
            showJump: false
            onPageSizeUpdated: function(size) {
                pageSize = size
                totalCount = 86
                totalPage = Math.ceil(totalCount / pageSize)
            }
        }

        EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

        // ========== EasyTransfer ==========
        Text {
            text: "穿梭框 (EasyTransfer)"
            font.pixelSize: 16
            font.bold: true
            color: EasyTheme.color.text
        }
        ColumnLayout {
            spacing: 12
            Layout.fillWidth: true
            Text { text: "基础用法"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            EasyTransfer {
                id: sampleTransfer
                Layout.fillWidth: true
                Layout.preferredHeight: 280
                titleLeft: "可选功能"
                titleRight: "已选功能"
                sourceItems: [
                    { "label": "数据导出", "value": "export" },
                    { "label": "数据导入", "value": "import" },
                    { "label": "自动备份", "value": "backup" },
                    { "label": "定时任务", "value": "schedule" },
                    { "label": "消息推送", "value": "push" },
                    { "label": "日志记录", "value": "log" },
                    { "label": "性能监控", "value": "monitor" },
                    { "label": "用户管理", "value": "user" }
                ]
                targetItems: []
                onChanged: resultText.text = "已选: " + sampleTransfer.getTargetLabels().join(", ")
            }
            Text {
                id: resultText
                font.pixelSize: 12
                color: EasyTheme.color.secondary
                text: "已选: (无)"
            }

            Text { text: "不同尺寸"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            EasyTransfer {
                Layout.fillWidth: true
                Layout.preferredHeight: 220
                size: EasyTheme.size.sizeSmall
                titleLeft: "小尺寸"
                titleRight: "已选"
                sourceItems: [
                    { "label": "选项A", "value": "a" },
                    { "label": "选项B", "value": "b" },
                    { "label": "选项C", "value": "c" },
                    { "label": "选项D", "value": "d" }
                ]
                targetItems: []
            }
        }
    }
}
