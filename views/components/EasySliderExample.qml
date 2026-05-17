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

    // ========== EasySlider ==========
    Text {
        text: "滑块 (EasySlider)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    ColumnLayout {
        spacing: 16
        width: parent.width
        EasySlider { value: 30; width: 300 }
        EasySlider { value: 70; width: 300 }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasyRate ==========
    Text {
        text: "评分 (EasyRate)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    ColumnLayout {
        spacing: 12
        width: parent.width
        Text { text: "基础评分"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        RowLayout {
            spacing: 24
            EasyRate { id: rate1; value: 3 }
            Text { text: "当前评分: " + rate1.value; font.pixelSize: 12; color: EasyTheme.color.text }
        }
        Text { text: "半星评分"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        EasyRate { id: rate2; value: 3.5; allowHalf: true }
        Text { text: "只读评分"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        RowLayout {
            spacing: 32
            EasyRate { value: 4; readonly: true }
            EasyRate { value: 3.5; readonly: true; allowHalf: true }
            EasyRate { value: 0; readonly: true }
        }
    }

    EasyDivider { Layout.fillWidth: true; orientation: Qt.Horizontal }

    // ========== EasySegmented ==========
    Text {
        text: "分段控制器 (EasySegmented)"
        font.pixelSize: 16
        font.bold: true
        color: EasyTheme.color.text
    }
    ColumnLayout {
        spacing: 12
        width: parent.width
        Text { text: "不同尺寸"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        RowLayout {
            spacing: 16
            EasySegmented { options: [{"text": "日"}, {"text": "周"}]; currentIndex: 0; size: EasyTheme.size.sizeMini }
            EasySegmented { options: [{"text": "日"}, {"text": "周"}]; currentIndex: 0; size: EasyTheme.size.sizeSmall }
            EasySegmented { options: [{"text": "日"}, {"text": "周"}]; currentIndex: 0 }
            EasySegmented { options: [{"text": "日"}, {"text": "周"}]; currentIndex: 0; size: EasyTheme.size.sizeLarge }
        }
        Text { text: "单选"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        EasySegmented {
            id: seg1
            options: [{"text": "日"}, {"text": "周"}, {"text": "月"}, {"text": "年"}]
            currentIndex: 1
        }
        Text { text: "多选"; font.pixelSize: 12; color: EasyTheme.color.placeholder }
        EasySegmented {
            id: seg2
            exclusive: false
            options: [{"text": "加粗"}, {"text": "斜体"}, {"text": "下划线"}, {"text": "删除线"}]
            currentIndices: [0, 2]
        }
    }
    }
}
