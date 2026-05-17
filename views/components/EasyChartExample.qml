import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI

Item {
    id: root
    implicitHeight: chartCol.implicitHeight + 48

    ColumnLayout {
        id: chartCol
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 24 }
        spacing: 24

        Text { text: "折线图"; font.pixelSize: 18; font.bold: true; color: EasyTheme.color.text }
        EasyChart {
            Layout.fillWidth: true; implicitHeight: 240
            chartType: EasyChart.ChartType.Line
            showGrid: true; showLabels: true; animated: true
            dataPoints: [
                { label: "周一", value: 22 }, { label: "周二", value: 28 },
                { label: "周三", value: 25 }, { label: "周四", value: 32 },
                { label: "周五", value: 30 }, { label: "周六", value: 38 },
                { label: "周日", value: 36 }
            ]
        }

        Text { text: "柱状图"; font.pixelSize: 18; font.bold: true; color: EasyTheme.color.text }
        EasyChart {
            Layout.fillWidth: true; implicitHeight: 240
            chartType: EasyChart.ChartType.Bar; showGrid: true
            dataPoints: [
                { label: "桌面端", value: 45, color: "#6366f1" },
                { label: "移动端", value: 32, color: "#10b981" },
                { label: "平板", value: 15, color: "#f59e0b" },
                { label: "其他", value: 8, color: "#ec4899" }
            ]
        }

        Text { text: "环形图"; font.pixelSize: 18; font.bold: true; color: EasyTheme.color.text }
        EasyChart {
            Layout.fillWidth: true; implicitHeight: 240
            chartType: EasyChart.ChartType.Donut; showLegend: true
            centerText: "100%"; centerSubText: "访问占比"
            dataPoints: [
                { label: "桌面端", value: 35, color: "#6366f1" },
                { label: "移动端", value: 25, color: "#10b981" },
                { label: "平板", value: 20, color: "#f59e0b" },
                { label: "其他", value: 20, color: "#ec4899" }
            ]
        }

        Text { text: "饼图"; font.pixelSize: 18; font.bold: true; color: EasyTheme.color.text }
        EasyChart {
            Layout.fillWidth: true; implicitHeight: 240
            chartType: EasyChart.ChartType.Pie; showLabels: true; showLegend: true
            dataPoints: [
                { label: "已完成", value: 65, color: "#10b981" },
                { label: "进行中", value: 25, color: "#6366f1" },
                { label: "待处理", value: 10, color: "#f59e0b" }
            ]
        }
    }
}
