import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI

Control {
    id: root
    implicitWidth: 560; implicitHeight: 420

    property int currentStep: 0
    property var steps: []          // [{title, subtitle, content: Component}]
    property bool showStepNumbers: true
    property string finishText: "完成"
    property string nextText: "下一步"
    property string backText: "上一步"
    property string cancelText: "取消"
    property bool allowCancel: true

    signal finished()
    signal cancelled()

    readonly property int totalSteps: steps.length
    readonly property bool isFirstStep: currentStep === 0
    readonly property bool isLastStep: currentStep === totalSteps - 1

    background: Rectangle {
        color: EasyTheme.color.card; radius: 14
        border.color: EasyTheme.color.cardBorder; border.width: EasyTheme.size.borderWidth
    }

    contentItem: ColumnLayout {
        spacing: 0

        // ── Step indicator ──
        Item {
            Layout.fillWidth: true; Layout.preferredHeight: 72
            Row {
                anchors.centerIn: parent; spacing: 6
                Repeater {
                    model: root.totalSteps
                    delegate: Row {
                        spacing: 6
                        Rectangle {
                            width: root.currentStep > index ? 28 : (root.currentStep === index ? 32 : 28)
                            height: root.currentStep > index ? 28 : (root.currentStep === index ? 32 : 28)
                            radius: width / 2
                            color: root.currentStep >= index ? EasyTheme.color.primary : EasyTheme.color.border
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on width { NumberAnimation { duration: 200 } }
                            Behavior on height { NumberAnimation { duration: 200 } }

                            Text {
                                anchors.centerIn: parent
                                text: root.currentStep > index ? "✓" : String(index + 1)
                                font.pixelSize: root.currentStep === index ? 14 : 12; font.bold: true
                                color: root.currentStep >= index ? "white" : EasyTheme.color.placeholder
                            }
                        }
                        Rectangle {
                            visible: index < root.totalSteps - 1
                            width: 40; height: 2; anchors.verticalCenter: parent.verticalCenter
                            color: root.currentStep > index ? EasyTheme.color.primary : EasyTheme.color.border
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }
                }
            }
        }

        // ── Step title ──
        ColumnLayout {
            Layout.fillWidth: true; Layout.preferredHeight: implicitHeight
            Layout.leftMargin: 24; Layout.rightMargin: 24; spacing: 2
            visible: root.steps.length > 0 && root.steps[root.currentStep] !== undefined

            Text {
                text: root.showStepNumbers ? "步骤 " + (root.currentStep + 1) + "/" + root.totalSteps : ""
                font.pixelSize: 11; color: EasyTheme.color.secondary
                visible: root.showStepNumbers
            }
            Text {
                Layout.fillWidth: true
                text: root.steps.length > 0 ? (root.steps[root.currentStep].title || "") : ""
                font.pixelSize: 18; font.bold: true; color: EasyTheme.color.text
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: root.steps.length > 0 ? (root.steps[root.currentStep].subtitle || "") : ""
                font.pixelSize: 12; color: EasyTheme.color.secondary; wrapMode: Text.WordWrap
                visible: text.length > 0
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; Layout.topMargin: 16; color: EasyTheme.color.divider }

        // ── Step content ──
        Item {
            Layout.fillWidth: true; Layout.fillHeight: true; Layout.margins: 24
            Loader {
                anchors.fill: parent
                sourceComponent: root.steps.length > 0 ? root.steps[root.currentStep].content : null
            }
        }

        // ── Buttons ──
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: EasyTheme.color.divider }

        RowLayout {
            Layout.fillWidth: true; Layout.preferredHeight: 52
            Layout.leftMargin: 16; Layout.rightMargin: 16; spacing: 8

            EasyButton {
                text: root.cancelText; visible: root.allowCancel
                primary: false
                onClicked: root.cancelled()
            }

            Item { Layout.fillWidth: true }

            EasyButton {
                text: root.backText; visible: !root.isFirstStep
                primary: false
                onClicked: { if (root.currentStep > 0) root.currentStep-- }
            }

            EasyButton {
                text: root.isLastStep ? root.finishText : root.nextText
                onClicked: {
                    if (root.isLastStep) root.finished()
                    else root.currentStep++
                }
            }
        }
    }
}
