import QtQuick
import QtQuick.Controls.Basic
import EasyUI

/**
 * EasyIPInput —— IP地址输入框
 *
 * 属性：
 *   ipAddress    {string}  IP地址值 (如 "192.168.1.1")
 *   enabled      {bool}    是否可用，默认 true
 *   placeholder  {string}  占位提示文字
 *   size         {int}     控件尺寸，默认 EasyTheme.size.sizeNormal
 *                         可选值：
 *                           EasyTheme.size.sizeMini    (24px)
 *                           EasyTheme.size.sizeSmall   (28px)
 *                           EasyTheme.size.sizeNormal  (36px)
 *                           EasyTheme.size.sizeLarge   (44px)
 *
 * 信号：
 *   accepted()             回车确认
 */
Rectangle {
    id: root

    property string ipAddress: ""
    property bool enabled: true
    property string placeholder: "255.255.255.255"
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

    Behavior on border.color {
        ColorAnimation {
            duration: 150
        }
    }

    // 存储各段值
    property var segments: ["", "", "", ""]

    // 验证IP段 (0-255)
    function validateSegment(value) {
        var num = parseInt(value);
        if (value === "")
            return true;
        if (isNaN(num) || num < 0 || num > 255)
            return false;
        // 防止前导零（除了 "0" 本身）
        if (value.length > 1 && value[0] === '0')
            return false;
        return true;
    }

    // 获取完整IP地址
    function getIP() {
        return segments.join(".");
    }

    // 设置IP地址
    function setIP(newIP) {
        var parts = newIP.split(".");
        for (var i = 0; i < 4; i++) {
            segments[i] = (parts[i] !== undefined) ? parts[i] : "";
        }
    }

    // 处理输入
    function handleInput(index, value) {
        // 过滤非数字字符
        value = value.replace(/[^0-9]/g, "");

        // 限制3位
        if (value.length > 3) {
            value = value.substring(0, 3);
        }

        // 限制在 0-255
        if (value.length === 3) {
            var num = parseInt(value);
            if (num > 255)
                value = "255";
        }

        // 禁止前导零（除了 "0" 本身）
        if (value.length > 1 && value[0] === '0') {
            value = value.substring(1);
        }

        segments[index] = value;
        ipAddress = getIP();

        // 更新 TextInput 显示处理后的值
        var input = getSegmentInput(index);
        if (input && input.text !== value) {
            input.text = value;
        }

        // 输入满3位自动跳到下一段
        if (value.length === 3 && index < 3) {
            Qt.callLater(function () {
                var nextInput = getSegmentInput(index + 1);
                if (nextInput) {
                    nextInput.forceActiveFocus();
                    nextInput.selectAll();
                }
            });
        }
    }

    // 获取段输入框引用
    function getSegmentInput(index) {
        if (index < 0 || index >= 4)
            return null;
        return segmentItems.children[index * 2];
    }

    // 处理焦点切换
    function handleTab(index) {
        if (index < 3) {
            var input = getSegmentInput(index + 1);
            if (input)
                input.forceActiveFocus();
        }
    }

    // 处理退格键
    function handleBackspace(index) {
        if (segments[index] === "" && index > 0) {
            var input = getSegmentInput(index - 1);
            if (input) {
                input.forceActiveFocus();
                input.selectAll();
            }
        }
    }

    // 处理点号键
    function handleDot(index) {
        if (index < 3) {
            var input = getSegmentInput(index + 1);
            if (input) {
                input.forceActiveFocus();
                input.selectAll();
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

        // 四个IP段 + 三个点号
        Row {
            id: segmentItems
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            // 手动创建4个输入段和3个点号
            TextInput {
                id: seg0
                width: (inputArea.width - 18) / 4
                height: inputArea.height
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: root.computedFontSize
                color: enabled ? EasyTheme.color.text : EasyTheme.color.placeholder
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
                enabled: root.enabled
                maximumLength: 3
                inputMethodHints: Qt.ImhDigitsOnly
                text: segments[0]
                onTextChanged: handleInput(0, text)
                onActiveFocusChanged: if (activeFocus)
                    selectAll()
                Keys.onPressed: event => handleKeyEvent(0, event)
            }
            Text {
                width: 6
                height: inputArea.height
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: "."
                font.pixelSize: root.computedFontSize + 2
                font.bold: true
                color: EasyTheme.color.placeholder
            }
            TextInput {
                id: seg1
                width: (inputArea.width - 18) / 4
                height: inputArea.height
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: root.computedFontSize
                color: enabled ? EasyTheme.color.text : EasyTheme.color.placeholder
                enabled: root.enabled
                maximumLength: 3
                inputMethodHints: Qt.ImhDigitsOnly
                text: segments[1]
                onTextChanged: handleInput(1, text)
                onActiveFocusChanged: if (activeFocus)
                    selectAll()
                Keys.onPressed: event => handleKeyEvent(1, event)
            }
            Text {
                width: 6
                height: inputArea.height
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: "."
                font.pixelSize: root.computedFontSize + 2
                font.bold: true
                color: EasyTheme.color.placeholder
            }
            TextInput {
                id: seg2
                width: (inputArea.width - 18) / 4
                height: inputArea.height
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: root.computedFontSize
                color: enabled ? EasyTheme.color.text : EasyTheme.color.placeholder
                enabled: root.enabled
                maximumLength: 3
                inputMethodHints: Qt.ImhDigitsOnly
                text: segments[2]
                onTextChanged: handleInput(2, text)
                onActiveFocusChanged: if (activeFocus)
                    selectAll()
                Keys.onPressed: event => handleKeyEvent(2, event)
            }
            Text {
                width: 6
                height: inputArea.height
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: "."
                font.pixelSize: root.computedFontSize + 2
                font.bold: true
                color: EasyTheme.color.placeholder
            }
            TextInput {
                id: seg3
                width: (inputArea.width - 18) / 4
                height: inputArea.height
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: root.computedFontSize
                color: enabled ? EasyTheme.color.text : EasyTheme.color.placeholder
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
                enabled: root.enabled
                maximumLength: 3
                inputMethodHints: Qt.ImhDigitsOnly
                text: segments[3]
                onTextChanged: handleInput(3, text)
                onActiveFocusChanged: if (activeFocus)
                    selectAll()
                Keys.onPressed: event => handleKeyEvent(3, event)
            }
        }
    }

    // 处理按键事件
    function handleKeyEvent(index, event) {
        if (event.key === Qt.Key_Tab) {
            event.accepted = true;
            handleTab(index);
        } else if (event.key === Qt.Key_Backspace) {
            if (segments[index] === "" && index > 0) {
                handleBackspace(index);
            }
        } else if (event.key === Qt.Key_Space || event.key === Qt.Key_Period) {
            event.accepted = true;
            handleDot(index);
        } else if (event.key === Qt.Key_Left) {
            var input = getSegmentInput(index);
            if (input && input.cursorPosition === 0 && index > 0) {
                event.accepted = true;
                var prevInput = getSegmentInput(index - 1);
                if (prevInput) {
                    prevInput.forceActiveFocus();
                    prevInput.cursorPosition = prevInput.length;
                }
            }
        } else if (event.key === Qt.Key_Right) {
            var currInput = getSegmentInput(index);
            if (currInput && currInput.cursorPosition === currInput.length && index < 3) {
                event.accepted = true;
                var nextInput = getSegmentInput(index + 1);
                if (nextInput) {
                    nextInput.forceActiveFocus();
                    nextInput.cursorPosition = 0;
                }
            }
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.accepted();
        }
    }

    // 占位文字
    Text {
        visible: ipAddress === "" || ipAddress === "..."
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
        onPressed: mouse => mouse.accepted = false
    }

    signal accepted
}
