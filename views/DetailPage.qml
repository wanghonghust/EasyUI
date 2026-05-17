// DetailPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import Handler 1.0

Item {
    id: detailPage
    property var userId
    property var navigator

    // 状态标志：控制控制面板的显示/隐藏
    property bool controlsVisible: true
    property int hideTimerDelay: 3000 // 3秒后隐藏

    // 自动隐藏计时器
    Timer {
        id: hideTimer
        interval: hideTimerDelay
        running: player.playbackState === MediaPlayer.PlayingState
                 && controlsVisible
        onTriggered: {
            if (mouseArea.containsMouse) {
                restart()
            } else {
                controlsVisible = false
            }
        }
    }

    // 全局鼠标区域，用于检测用户活动
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton // 不拦截点击事件，只检测移动

        onPositionChanged: {
            if (!controlsVisible) {
                controlsVisible = true
                hideTimer.restart()
            }
        }
        onClicked: {
            // 点击视频区域切换播放/暂停
            if (player.playbackState === MediaPlayer.PlayingState) {
                player.pause()
            } else {
                player.play()
            }
        }
    }

    MediaPlayer {
        id: player
        source: "file:///F:/DJI_001/DJI_20231003153918_0159_D.MP4"
        videoOutput: videoOutput
        audioOutput: AudioOutput {
            id: audioOutput
            volume: volumeSlider.value
        }

        onErrorOccurred: (error, errorString) => {
                             console.error("播放错误:", error, errorString)
                             statusText.text = "错误: " + errorString
                             statusText.visible = true
                         }

        onPlaybackStateChanged: {
            if (playbackState === MediaPlayer.PlayingState) {
                playBtn.icon.name = "media-playback-pause"
                hideTimer.start()
            } else if (playbackState === MediaPlayer.PausedState) {
                playBtn.icon.name = "media-playback-start"
                controlsVisible = true // 暂停时始终显示控制栏
                hideTimer.stop()
            } else if (playbackState === MediaPlayer.StoppedState) {
                playBtn.icon.name = "media-playback-start"
            }
        }

        onPositionChanged: position => {
                               if (!seekSlider.pressed && player.duration > 0) {
                                   seekSlider.value = position / player.duration
                               }
                               updateTimeLabels()
                           }

        onDurationChanged: {
            if (player.duration > 0)
                updateTimeLabels()
        }
    }

    // 视频显示区域
    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectFit

        // 加载中动画
        BusyIndicator {
            anchors.centerIn: parent
            width: 64
            height: 64
            running: player.playbackState === MediaPlayer.BufferingState
                     || (player.playbackState === MediaPlayer.LoadingState)
            visible: running
        }

        // 错误提示
        Text {
            id: statusText
            anchors.centerIn: parent
            color: "#ff6b6b"
            font.pixelSize: 20
            font.bold: true
            visible: text !== "" && text !== "00:00 / 00:00"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            anchors.margins: 20
        }
    }

    // 控制面板容器
    Rectangle {
        id: controlPanel
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        color: "#CC000000" // 深黑半透明

        // 顶部渐变遮罩，让过渡更自然
        Gradient {
            id: panelGradient
            orientation: Gradient.Vertical
            GradientStop {
                position: 0.0
                color: "#00000000"
            }
            GradientStop {
                position: 0.3
                color: "#CC000000"
            }
        }
        Rectangle {
            anchors.fill: parent
            gradient: panelGradient
            z: -1
        }

        visible: controlsVisible
        opacity: visible ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15

            // 播放/暂停按钮
            Button {
                id: playBtn
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                background: Rectangle {
                    color: playBtn.down ? "#ffffff" : "#00ffffff"
                    radius: 20
                    border.color: "#ffffff"
                    border.width: 2
                }
                contentItem: Image {
                    source: playBtn.icon.name === "media-playback-pause" ? "qrc:/qt/qml/QtQuick/Controls/Material/images/pause.png" : "qrc:/qt/qml/QtQuick/Controls/Material/images/play.png"
                    // 注意：如果没有内置图标资源，建议使用 Icon { name: "..." } 并配置 Theme
                    // 这里为了通用性，下面改用 Icon 组件
                    visible: false
                }
                // 使用标准的 Icon 组件替代 Image 以获得更好的主题支持
                icon.name: "media-playback-start"
                icon.color: "#ffffff"
                icon.width: 24
                icon.height: 24

                onClicked: {
                    Handler.setName("asdasd")
                    let name = Handler.name
                    console.log("name",name)
                    if (player.playbackState === MediaPlayer.PlayingState) {
                        player.pause()
                    } else {
                        player.play()
                    }
                }
            }

            // 停止按钮
            Button {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                icon.name: "media-playback-stop"
                icon.color: "#ffffff"
                icon.width: 20
                icon.height: 20
                background: Rectangle {
                    color: down ? "#33ffffff" : "#00ffffff"
                    radius: 20
                }
                onClicked: player.stop()
            }

            // 进度条区域
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                // 自定义样式的 Slider (进度条)
                Slider {
                    id: seekSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 1
                    value: 0

                    background: Rectangle {
                        x: seekSlider.leftPadding
                        y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                        width: seekSlider.availableWidth
                        height: 6
                        radius: 3
                        color: "#44ffffff"

                        Rectangle {
                            width: seekSlider.visualPosition * parent.width
                            height: parent.height
                            color: "#4fc3f7" // 亮蓝色进度
                            radius: 3
                        }
                    }

                    handle: Rectangle {
                        x: seekSlider.leftPadding + seekSlider.visualPosition
                           * (seekSlider.availableWidth - width)
                        y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 8
                        color: seekSlider.pressed ? "#ffffff" : "#4fc3f7"
                        border.color: "#ffffff"
                        visible: seekSlider.hovered || seekSlider.pressed
                                 || controlsVisible
                    }

                    onPressedChanged: {
                        if (!pressed) {
                            player.position = value * player.duration
                        }
                    }
                }

                // 时间文本
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        id: currentTimeText
                        color: "#eeeeee"
                        font.pixelSize: 12
                        font.family: "Consolas" // 等宽字体防止数字跳动
                        text: "00:00"
                    }

                    Item {
                        Layout.fillWidth: true
                    } // Spacer

                    Text {
                        id: totalTimeText
                        color: "#aaaaaa"
                        font.pixelSize: 12
                        font.family: "Consolas"
                        text: "00:00"
                    }
                }
            }

            // 音量控制
            RowLayout {
                spacing: 8

                Button {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    icon.name: volumeSlider.value > 0.5 ? "audio-volume-high" : (volumeSlider.value > 0 ? "audio-volume-medium" : "audio-volume-muted")
                    icon.color: "#ffffff"
                    icon.width: 20
                    icon.height: 20
                    background: Rectangle {
                        color: "#00ffffff"
                        radius: 15
                    }
                    onClicked: {
                        if (volumeSlider.value > 0) {
                            volumeSlider.lastValue = volumeSlider.value
                            volumeSlider.value = 0
                        } else {
                            volumeSlider.value = volumeSlider.lastValue || 0.5
                        }
                    }
                    property real lastValue: 0.5
                }

                Slider {
                    id: volumeSlider
                    Layout.preferredWidth: 80
                    from: 0
                    to: 1
                    value: 0.5

                    background: Rectangle {
                        x: volumeSlider.leftPadding
                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                        width: volumeSlider.availableWidth
                        height: 4
                        radius: 2
                        color: "#44ffffff"
                        Rectangle {
                            width: volumeSlider.visualPosition * parent.width
                            height: parent.height
                            color: "#ffffff"
                            radius: 2
                        }
                    }
                    handle: Rectangle {
                        x: volumeSlider.leftPadding + volumeSlider.visualPosition
                           * (volumeSlider.availableWidth - width)
                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                        implicitWidth: 12
                        implicitHeight: 12
                        radius: 6
                        color: "#ffffff"
                        visible: volumeSlider.hovered || volumeSlider.pressed
                    }
                }
            }
        }
    }

    function updateTimeLabels() {
        currentTimeText.text = formatTime(player.position)
        totalTimeText.text = formatTime(player.duration)
    }

    function formatTime(ms) {
        if (!ms || ms < 0)
            return "00:00"
        let totalSeconds = Math.floor(ms / 1000)
        let minutes = Math.floor(totalSeconds / 60)
        let seconds = totalSeconds % 60
        return minutes.toString().padStart(2, '0') + ":" + seconds.toString(
                    ).padStart(2, '0')
    }
}
