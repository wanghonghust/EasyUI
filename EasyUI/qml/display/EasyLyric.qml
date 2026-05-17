import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI

/**
 * EasyLyric —— 歌词显示组件
 *
 * 功能：
 *   - 支持LRC格式歌词解析
 *   - 根据播放时间高亮当前行
 *   - 自动滚动到当前播放行
 *   - 卡拉OK风格文字逐渐变色效果
 *   - 适配EasyTheme主题样式
 *
 * 属性：
 *   lyricText       {string}  LRC格式歌词文本
 *   currentTime     {int}     当前播放时间（毫秒）
 *   lineHeight      {int}     每行高度，默认 40
 *   karaokeMode     {bool}    是否启用卡拉OK渐变效果，默认 true
 *   normalColor     {color}   普通歌词颜色
 *   highlightColor  {color}   高亮歌词颜色
 *   progressColor   {color}   渐变进度颜色（卡拉OK模式）
 *   showTimeInfo    {bool}    是否显示时间信息和跳转按钮，默认 true
 *
 * 信号：
 *   jumpToTime(time)  请求跳转到指定时间点（毫秒）
 *
 * 示例：
 *   EasyLyric {
 *       lyricText: "[00:00.00]第一行歌词\n[00:05.00]第二行歌词"
 *       currentTime: player.position  // 绑定播放器时间（毫秒）
 *       karaokeMode: true  // 启用卡拉OK效果
 *       onJumpToTime: function(time) { player.seek(time) }
 *   }
 */
Item {
    id: root

    property string lyricText: ""
    property int currentTime: 0  // 毫秒
    property int lineHeight: 40
    property bool karaokeMode: true  // 卡拉OK渐变效果
    property bool showTimeInfo: true  // 显示时间信息和跳转按钮

    // 颜色配置
    property color normalColor: EasyTheme.color.secondary
    property color highlightColor: EasyTheme.color.primary
    property color progressColor: EasyTheme.color.accent  // 渐变进度颜色

    // 解析后的歌词列表 [{time: 毫秒, endTime: 毫秒, text: "歌词"}, ...]
    property var lyricLines: []

    // 当前高亮行索引
    property int currentLineIndex: -1

    // 当前行内的播放进度 (0.0 - 1.0)
    property real currentLineProgress: 0.0

    // 自动滚动开关
    property bool autoScroll: true

    // 跳转信号
    signal jumpToTime(int time)

    implicitWidth: 300
    implicitHeight: lyricListView.contentHeight

    // 解析LRC歌词
    onLyricTextChanged: {
        parseLyric()
    }

    // 根据当前时间更新高亮行和进度
    onCurrentTimeChanged: {
        updateCurrentLine()
    }

    // 解析LRC格式歌词
    function parseLyric() {
        var lines = []
        if (!lyricText || lyricText.trim() === "") {
            lyricLines = lines
            return
        }

        var rawLines = lyricText.split('\n')
        for (var i = 0; i < rawLines.length; i++) {
            var line = rawLines[i].trim()
            if (!line) continue

            // 匹配时间标签 [mm:ss.xx] 或 [mm:ss.xxx]
            var match = line.match(/\[(\d{2}):(\d{2})\.(\d{2,3})\]/)
            if (match) {
                var minutes = parseInt(match[1])
                var seconds = parseInt(match[2])
                var ms = parseInt(match[3])
                // 补齐毫秒位数（2位乘10，3位不变）
                if (match[3].length === 2) {
                    ms = ms * 10
                }
                var time = minutes * 60 * 1000 + seconds * 1000 + ms

                // 提取歌词文本（去除时间标签）
                var text = line.replace(/\[\d{2}:\d{2}\.\d{2,3}\]/g, '').trim()

                if (text) {
                    lines.push({
                        time: time,
                        endTime: -1,  // 暂时未知，后续填充
                        text: text,
                        duration: 0   // 暂时未知
                    })
                }
            }
        }

        // 按时间排序
        lines.sort(function(a, b) { return a.time - b.time })

        // 计算每行的结束时间和持续时间
        for (var i = 0; i < lines.length; i++) {
            if (i < lines.length - 1) {
                lines[i].endTime = lines[i + 1].time
            } else {
                //最后一行，假设持续5秒
                lines[i].endTime = lines[i].time + 5000
            }
            lines[i].duration = lines[i].endTime - lines[i].time
        }

        lyricLines = lines
        currentLineIndex = -1
        currentLineProgress = 0.0
    }

    // 根据当前时间找到对应的歌词行并计算进度
    function updateCurrentLine() {
        if (lyricLines.length === 0) {
            currentLineIndex = -1
            currentLineProgress = 0.0
            return
        }

        // 找到当前时间对应的行（时间小于等于当前时间的最后一行）
        var newIndex = -1
        var progress = 0.0

        for (var i = 0; i < lyricLines.length; i++) {
            var line = lyricLines[i]
            if (currentTime >= line.time) {
                newIndex = i
                // 计算行内进度
                if (currentTime < line.endTime) {
                    progress = (currentTime - line.time) / line.duration
                    progress = Math.max(0.0, Math.min(1.0, progress))
                } else {
                    progress = 1.0
                }
            } else {
                // 当前时间小于此行开始时间，后面的行都不匹配了
                break
            }
        }

        // 更新状态
        if (newIndex !== currentLineIndex) {
            currentLineIndex = newIndex
            // 自动滚动到当前行
            if (autoScroll && currentLineIndex >= 0) {
                scrollToCurrentLine()
            }
        }

        // 始终更新进度（用于卡拉OK效果）
        currentLineProgress = progress
    }

    // 滚动到当前高亮行
    function scrollToCurrentLine() {
        if (currentLineIndex < 0) return

        // 将当前行滚动到视图中央
        var targetY = currentLineIndex * (lineHeight + lyricListView.spacing) - lyricListView.height / 2 + lineHeight / 2
        targetY = Math.max(0, Math.min(targetY, lyricListView.contentHeight - lyricListView.height))

        scrollAnimation.to = targetY
        scrollAnimation.start()
    }

    // 歌词列表视图
    ListView {
        id: lyricListView
        anchors.fill: parent
        clip: true

        model: lyricLines
        delegate: lyricDelegate
        spacing: 4

        // 禁止用户滚动时自动滚动
        interactive: true
        flickDeceleration: 5000

        // 滚动动画
        NumberAnimation on contentY {
            id: scrollAnimation
            duration: 300
            easing.type: Easing.OutCubic
            running: false
        }

        // 用户滚动时暂停自动滚动
        onMovingChanged: {
            if (moving) {
                autoScroll = false
            }
        }

        // 滚动结束后恢复自动滚动（延迟2秒）
        onMovementEnded: {
            restoreTimer.start()
        }

        Timer {
            id: restoreTimer
            interval: 2000
            onTriggered: {
                autoScroll = true
                scrollToCurrentLine()
            }
        }

        // 空状态提示
        Label {
            anchors.centerIn: parent
            text: qsTr("暂无歌词")
            font.pixelSize: 14
            color: EasyTheme.color.placeholder
            visible: lyricLines.length === 0
        }
    }

    // 歌词行委托（支持卡拉OK渐变效果）
    Component {
        id: lyricDelegate

        Item {
            id: lineItem
            width: lyricListView.width
            height: lineHeight

            required property int index
            required property var modelData

            // 是否是当前高亮行（直接绑定，不手动赋值）
            property bool isCurrent: index === root.currentLineIndex

            // 当前行渐变进度
            property real lineProgress: isCurrent ? root.currentLineProgress : (index < root.currentLineIndex ? 1.0 : 0.0)

            // 悬停状态
            property bool isHovered: hoverHandler.hovered

            // 格式化时间函数
            function formatTime(ms) {
                var minutes = Math.floor(ms / 60000)
                var seconds = Math.floor((ms % 60000) / 1000)
                return String(minutes).padStart(2, '0') + ":" + String(seconds).padStart(2, '0')
            }

            // 高亮动画
            Behavior on scale {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            scale: isCurrent ? 1.05 : 1.0

            // 悬停检测
            HoverHandler {
                id: hoverHandler
                acceptedDevices: PointerDevice.Mouse | PointerDevice.Touch
            }

            // 左侧开始时间
            Label {
                id: startTimeLabel
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: formatTime(modelData.time)
                font.pixelSize: 12
                font.family: "Consolas, Monaco, monospace"
                color: root.normalColor
                opacity: root.showTimeInfo && isHovered ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }

            // 歌词文字区域
            Item {
                id: textContainer
                anchors.centerIn: parent
                width: lineTextMetrics.width
                height: lineTextMetrics.height
                clip: true

                // 底层文字（未唱部分颜色）- 完整显示
                Label {
                    id: baseText
                    anchors.centerIn: parent
                    text: modelData.text || ""
                    font.pixelSize: lineItem.isCurrent ? 16 : 14
                    font.bold: lineItem.isCurrent
                    color: {
                        if (lineItem.isCurrent) {
                            return root.highlightColor  // 未唱部分颜色
                        } else if (lineItem.index < root.currentLineIndex) {
                            return root.highlightColor
                        } else {
                            return root.normalColor
                        }
                    }
                    wrapMode: Text.NoWrap

                    Behavior on font.pixelSize {
                        NumberAnimation { duration: 200 }
                    }
                }

                // 上层文字（已唱部分颜色）- 通过裁剪显示左侧部分
                Item {
                    id: clipContainer
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * lineItem.lineProgress
                    height: lineTextMetrics.height
                    clip: true
                    visible: root.karaokeMode && lineItem.isCurrent && lineItem.lineProgress > 0

                    Label {
                        id: overlayText
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.text || ""
                        font.pixelSize: lineItem.isCurrent ? 16 : 14
                        font.bold: lineItem.isCurrent
                        color: root.progressColor  // 已唱部分颜色
                        wrapMode: Text.NoWrap
                    }
                }
            }

            // 右侧结束时间和跳转按钮
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                opacity: root.showTimeInfo && isHovered ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }

                // 结束时间
                Label {
                    id: endTimeLabel
                    text: formatTime(modelData.endTime)
                    font.pixelSize: 12
                    font.family: "Consolas, Monaco, monospace"
                    color: root.normalColor
                }

                // 跳转按钮
                Rectangle {
                    id: jumpButton
                    width: 24
                    height: 24
                    radius: 4
                    color: jumpBtnArea.containsMouse ? root.highlightColor : root.normalColor
                    opacity: jumpBtnArea.containsMouse ? 1.0 : 0.6

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }

                    // 播放图标
                    EasyIconFont {
                        id: playIcon
                        anchors.centerIn: parent
                        icon: EasyIcon.material.play_arrow
                        iconSize: 16
                        color: "white"
                    }

                    MouseArea {
                        id: jumpBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.jumpToTime(modelData.time)
                        }
                    }
                }
            }

            // 文字测量
            TextMetrics {
                id: lineTextMetrics
                text: modelData.text || ""
                font.pixelSize: lineItem.isCurrent ? 16 : 14
                font.bold: lineItem.isCurrent
            }
        }
    }

    // 重置组件状态（不重置 currentTime，因为它可能是绑定的）
    function reset() {
        // 不要直接设置 currentTime，避免破坏外部绑定
        // 只重置内部状态
        currentLineIndex = -1
        currentLineProgress = 0.0
        lyricListView.contentY = 0
        autoScroll = true
        // 强制重新计算当前行
        updateCurrentLine()
    }
}