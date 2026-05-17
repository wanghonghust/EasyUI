import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI

Item {
    id: root
    implicitHeight: 400

    // Mock data
    property var cascadeModel: [
        {
            label: "北京",
            value: "beijing",
            children: [
                { label: "东城区", value: "dongcheng" },
                { label: "西城区", value: "xicheng" },
                { label: "朝阳区", value: "chaoyang",
                    children: [
                        { label: "望京街道", value: "wangjing" },
                        { label: "三里屯街道", value: "sanlitun" },
                        { label: "国贸街道", value: "guomao" }
                    ]
                },
                { label: "海淀区", value: "haidian",
                    children: [
                        { label: "中关村街道", value: "zhongguancun" },
                        { label: "五道口街道", value: "wudaokou" }
                    ]
                },
                { label: "丰台区", value: "fengtai" }
            ]
        },
        {
            label: "上海",
            value: "shanghai",
            children: [
                { label: "浦东新区", value: "pudong" },
                { label: "徐汇区", value: "xuhui",
                    children: [
                        { label: "田林街道", value: "tianlin" },
                        { label: "漕河泾街道", value: "caohejing" }
                    ]
                },
                { label: "静安区", value: "jingan" }
            ]
        },
        {
            label: "广东",
            value: "guangdong",
            children: [
                { label: "广州", value: "guangzhou",
                    children: [
                        { label: "天河区", value: "tianhe",
                            children: [
                                { label: "体育西路", value: "tiyuxilu" },
                                { label: "珠江新城", value: "zhujiang" }
                            ]
                        },
                        { label: "越秀区", value: "yuexiu" }
                    ]
                },
                { label: "深圳", value: "shenzhen",
                    children: [
                        { label: "南山区", value: "nanshan" },
                        { label: "福田区", value: "futian" }
                    ]
                }
            ]
        },
        { label: "浙江", value: "zhejiang" },
        { label: "四川", value: "sichuan" }
    ]

    ColumnLayout {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 24 }
        spacing: 20

        Text { text: "级联选择器"; font.pixelSize: 16; font.bold: true; color: EasyTheme.color.text }
        Text { text: "支持多级层级结构，逐级选择，适用于地区选择、分类筛选等场景。"; font.pixelSize: 13; color: EasyTheme.color.secondary; wrapMode: Text.WordWrap; Layout.fillWidth: true }

        // Basic usage
        ColumnLayout { spacing: 8
            Text { text: "基础用法（省市联动）"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            RowLayout { spacing: 12
                EasyCascader {
                    id: cascader1
                    model: root.cascadeModel
                    placeholder: "请选择地区"
                    onPathSelected: function(path) {
                        var labels = []
                        for (var i = 0; i < path.length; i++)
                            labels.push(path[i].label)
                        selectedText1.text = labels.join(" / ") || "未选择"
                    }
                }
                Text {
                    id: selectedText1
                    text: "未选择"
                    font.pixelSize: 13
                    color: EasyTheme.color.placeholder
                }
            }
        }

        // Pre-selected value
        ColumnLayout { spacing: 8
            Text { text: "带默认值"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            EasyCascader {
                id: cascader2
                model: root.cascadeModel
                selectedPath: [{label: "广东", value: "guangdong"}, {label: "广州", value: "guangzhou"}, {label: "天河区", value: "tianhe"}]
            }
        }

        // Different size
        ColumnLayout { spacing: 8
            Text { text: "不同尺寸"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            RowLayout { spacing: 12
                EasyCascader { model: root.cascadeModel; size: EasyTheme.size.sizeSmall; placeholder: "Small" }
                EasyCascader { model: root.cascadeModel; size: EasyTheme.size.sizeNormal; placeholder: "Normal" }
                EasyCascader { model: root.cascadeModel; size: EasyTheme.size.sizeLarge; placeholder: "Large" }
            }
        }

        // Disabled
        ColumnLayout { spacing: 8
            Text { text: "禁用状态"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
            EasyCascader { enabled: false; placeholder: "已禁用" }
        }
    }
}
