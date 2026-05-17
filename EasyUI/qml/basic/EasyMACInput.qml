import QtQuick
import QtQuick.Controls.Basic
import EasyUI

/**
 * EasyMACInput —— MAC地址输入框
 *
 * 属性：
 *   macAddress    {string}  MAC地址值 (如 "AA:BB:CC:DD:EE:FF")
 *   enabled       {bool}    是否可用，默认 true
 *   placeholder   {string}  占位提示文字
 *   separator     {string}  分隔符，默认 ":"
 *   size          {int}     控件尺寸，默认 EasyTheme.size.sizeNormal
 *                         可选值：
 *                           EasyTheme.size.sizeMini    (24px)
 *                           EasyTheme.size.sizeSmall   (28px)
 *                           EasyTheme.size.sizeNormal  (36px)
 *                           EasyTheme.size.sizeLarge   (44px)
 *
 * 信号：
 *   accepted()              回车确认
 */
Rectangle {
    id: root

    property string macAddress: ""
    property bool enabled: true
    property string placeholder: "AA:BB:CC:DD:EE:FF"
    property string separator: ":"
    property int size: EasyTheme.size.sizeNormal

    // 根据 size 计算控件尺寸
    readonly property int computedHeight: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.heightMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.heightSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.heightLarge
        default:                        return EasyTheme.size.heightNormal
        }
    }
    readonly property int computedPadding: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.paddingMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.paddingSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.paddingLarge
        default:                        return EasyTheme.size.paddingNormal
        }
    }
    readonly property int computedFontSize: {
        switch (size) {
        case EasyTheme.size.sizeMini:   return EasyTheme.size.fontSizeMini
        case EasyTheme.size.sizeSmall:  return EasyTheme.size.fontSizeSmall
        case EasyTheme.size.sizeLarge:  return EasyTheme.size.fontSizeLarge
        default:                        return EasyTheme.size.fontSizeNormal
        }
    }

    width: 220
    height: computedHeight
    radius: EasyTheme.size.radius
    color: EasyTheme.color.card
    border.color: inputArea.activeFocus ? EasyTheme.color.primary : EasyTheme.color.border
    border.width: inputArea.activeFocus ? EasyTheme.size.borderWidthActive : EasyTheme.size.borderWidth

    Behavior on border.color { ColorAnimation { duration: 150 } }

    // 存储各段值
    property var segments: ["", "", "", "", "", ""]

    // 验证MAC段 (00-FF)
    function validateSegment(value) {
        if (value === "") return true
        if (!/^[0-9A-Fa-f]{1,2}$/.test(value)) return false
        return true
    }

    // 获取完整MAC地址
    function getMAC() {
        return segments.join(separator)
    }

    // 设置MAC地址
    function setMAC(newMAC) {
        // 支持 : 或 - 分隔符
        var sep = newMAC.includes("-") ? "-" : ":"
        var parts = newMAC.split(sep)
        for (var i = 0; i < 6; i++) {
            segments[i] = (parts[i] !== undefined) ? parts[i].toUpperCase() : ""
        }
    }

    // 处理输入
    function handleInput(index, value) {
        // 过滤非十六进制字符
        value = value.replace(/[^0-9A-Fa-f]/g, "").toUpperCase()

        // 限制2位
        if (value.length > 2) {
            value = value.substring(0, 2)
        }

        segments[index] = value
        macAddress = getMAC()

        // 更新 TextInput 显示处理后的值
        var input = getSegmentInput(index)
        if (input && input.text !== value) {
            input.text = value
        }

        // 输入满2位自动跳到下一段
        if (value.length === 2 && index < 5) {
            Qt.callLater(function() {
                var nextInput = getSegmentInput(index + 1)
                if (nextInput) {
                    nextInput.forceActiveFocus()
                    nextInput.selectAll()
                }
            })
        }
    }

    // 获取段输入框引用
    function getSegmentInput(index) {
        if (index < 0 || index >= 6) return null
        return segmentItems.children[index * 2]
    }

    // 处理焦点切换
    function handleTab(index) {
        if (index < 5) {
            var input = getSegmentInput(index + 1)
            if (input) input.forceActiveFocus()
        }
    }

    // 处理退格键
    function handleBackspace(index) {
        if (segments[index] === "" && index > 0) {
            var input = getSegmentInput(index - 1)
            if (input) {
                input.forceActiveFocus()
                input.selectAll()
            }
        }
    }

    // 处理分隔符键
    function handleSeparator(index) {
        if (index < 5) {
            var input = getSegmentInput(index + 1)
            if (input) {
                input.forceActiveFocus()
                input.selectAll()
            }
        }
    }

    Row {
        id: inputArea
        anchors.fill: parent
        anchors.leftMargin: root.computedPadding
        anchors.rightMargin: root.computedPadding
        spacing: 0
        activeFocusOnTab: true

        // 六个MAC段 + 五个分隔符
        Row {
            id: segmentItems
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            property int segWidth: (inputArea.width - 25) / 6

            TextInput {
                id: mac0
                width: segmentItems.segWidth
                height: inputArea.height
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: root.computedFontSize
                color: enabled ? EasyTheme.color.text : EasyTheme.color.placeholder
                Behavior on color { ColorAnimation { duration: 150 } }
                enabled: root.enabled
                maximumLength: 2
                inputMethodHints: Qt.ImhUppercaseOnly
                text: segments[0]
                onTextChanged: handleInput(0, text)
                onActiveFocusChanged: if (activeFocus) selectAll()
                Keys.onPressed: (event) => handleKeyEvent(0, event)
            }
            Text {
                width: 5
                height: inputArea.height
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: separator
                font.pixelSize: root.computedFontSize
                font.bold: true
                color: EasyTheme.color.placeholder
            }
            TextInput {
                id: mac1
                width: segmentItems.segWidth
                height: inputArea.height
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: root.computedFontSize
                color: enabled ? EasyTheme.color.text : EasyTheme.color.placeholder
                Behavior on color { ColorAnimation { duration: 150 } }
                enabled: root.enabled
                maximumLength: 2
                inputMethodHints: Qt.ImhUppercaseOnly
                text: segments[1]
                onTextChanged: handleInput(1, text)
                onActiveFocusChanged: if (activeFocus) selectAll()
                Keys.onPressed: (event) => handleKeyEvent(1, event)
            }
            Text {
                width: 5
                height: inputArea.height
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: separator
                font.pixelSize: root.computedFontSize
                font.bold: true
                color: EasyTheme.color.placeholder
            }
            TextInput {
                id: mac2
                width: segmentItems.segWidth
                height: inputArea.height
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: root.computedFontSize
                color: enabled ? EasyTheme.color.text : EasyTheme.color.placeholder
                Behavior on color { ColorAnimation { duration: 150 } }
                enabled: root.enabled
                maximumLength: 2
                inputMethodHints: Qt.ImhUppercaseOnly
                text: segments[2]
                onTextChanged: handleInput(2, text)
                onActiveFocusChanged: if (activeFocus) selectAll()
                Keys.onPressed: (event) => handleKeyEvent(2, event)
            }
            Text {
                width: 5
                height: inputArea.height
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: separator
                font.pixelSize: root.computedFontSize
                font.bold: true
                color: EasyTheme.color.placeholder
            }
            TextInput {
                id: mac3
                width: segmentItems.segWidth
                height: inputArea.height
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: root.computedFontSize
                color: enabled ? EasyTheme.color.text : EasyTheme.color.placeholder
                Behavior on color { ColorAnimation { duration: 150 } }
                enabled: root.enabled
                maximumLength: 2
                inputMethodHints: Qt.ImhUppercaseOnly
                text: segments[3]
                onTextChanged: handleInput(3, text)
                onActiveFocusChanged: if (activeFocus) selectAll()
                Keys.onPressed: (event) => handleKeyEvent(3, event)
            }
            Text {
                width: 5
                height: inputArea.height
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: separator
                font.pixelSize: root.computedFontSize
                font.bold: true
                color: EasyTheme.color.placeholder
            }
            TextInput {
                id: mac4
                width: segmentItems.segWidth
                height: inputArea.height
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: root.computedFontSize
                color: enabled ? EasyTheme.color.text : EasyTheme.color.placeholder
                Behavior on color { ColorAnimation { duration: 150 } }
                enabled: root.enabled
                maximumLength: 2
                inputMethodHints: Qt.ImhUppercaseOnly
                text: segments[4]
                onTextChanged: handleInput(4, text)
                onActiveFocusChanged: if (activeFocus) selectAll()
                Keys.onPressed: (event) => handleKeyEvent(4, event)
            }
            Text {
                width: 5
                height: inputArea.height
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: separator
                font.pixelSize: root.computedFontSize
                font.bold: true
                color: EasyTheme.color.placeholder
            }
            TextInput {
                id: mac5
                width: segmentItems.segWidth
                height: inputArea.height
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: root.computedFontSize
                color: enabled ? EasyTheme.color.text : EasyTheme.color.placeholder
                Behavior on color { ColorAnimation { duration: 150 } }
                enabled: root.enabled
                maximumLength: 2
                inputMethodHints: Qt.ImhUppercaseOnly
                text: segments[5]
                onTextChanged: handleInput(5, text)
                onActiveFocusChanged: if (activeFocus) selectAll()
                Keys.onPressed: (event) => handleKeyEvent(5, event)
            }
        }
    }

    // 处理按键事件
    function handleKeyEvent(index, event) {
        if (event.key === Qt.Key_Tab) {
            event.accepted = true
            handleTab(index)
        } else if (event.key === Qt.Key_Backspace) {
            if (segments[index] === "" && index > 0) {
                handleBackspace(index)
            }
        } else if (event.key === Qt.Key_Space || event.key === Qt.Key_Colon || event.key === Qt.Key_Minus) {
            event.accepted = true
            handleSeparator(index)
        } else if (event.key === Qt.Key_Left) {
            var input = getSegmentInput(index)
            if (input && input.cursorPosition === 0 && index > 0) {
                event.accepted = true
                var prevInput = getSegmentInput(index - 1)
                if (prevInput) {
                    prevInput.forceActiveFocus()
                    prevInput.cursorPosition = prevInput.length
                }
            }
        } else if (event.key === Qt.Key_Right) {
            var currInput = getSegmentInput(index)
            if (currInput && currInput.cursorPosition === currInput.length && index < 5) {
                event.accepted = true
                var nextInput = getSegmentInput(index + 1)
                if (nextInput) {
                    nextInput.forceActiveFocus()
                    nextInput.cursorPosition = 0
                }
            }
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.accepted()
        }
    }

    // 占位文字
    Text {
        visible: macAddress === "" || macAddress === "::::::"
        anchors.left: parent.left
        anchors.leftMargin: root.computedPadding
        anchors.verticalCenter: parent.verticalCenter
        text: root.placeholder
        font.pixelSize: root.computedFontSize
        color: EasyTheme.color.placeholder
        z: -1
    }

    // 禁用时显示禁止光标
    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        cursorShape: root.enabled ? Qt.IBeamCursor : Qt.ForbiddenCursor
        propagateComposedEvents: true
        onPressed: (mouse) => { mouse.accepted = false }
    }

    signal accepted()
}
