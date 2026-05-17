import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import EasyUI


/**
 * EasyCarousel —— 轮播组件
 *
 * 属性：
 *   items           {list<var>}    轮播项数据列表，默认 []
 *   currentIndex    {int}          当前索引，默认 0
 *   autoPlay        {bool}         自动播放，默认 true
 *   interval        {int}          自动播放间隔(ms)，默认 3000
 *   showIndicators  {bool}         显示指示器，默认 true
 *   showArrows      {bool}         显示箭头按钮，默认 true
 *   indicatorStyle  {string}       指示器样式: "dots"/"bars"/"numbers"，默认 "dots"
 *   arrowStyle      {string}       箭头样式: "inside"/"outside"/"hover"，默认 "hover"
 *   height          {int}          轮播高度，默认 200
 *   radius          {int}          圆角大小，默认 8
 *
 * 信号：
 *   itemClicked(var item)           点击轮播项
 */
Rectangle {
    id: root

    property var items: []
    property int currentIndex: 0
    property bool autoPlay: true
    property int interval: 3000
    property bool showIndicators: true
    property bool showArrows: true
    property string indicatorStyle: "dots" // dots, bars, numbers
    property string arrowStyle: "hover" // inside, outside, hover
    property Component delegate: null  // 自定义轮播项组件
    property int carouselHeight: 200
    property int carouselRadius: 8

    signal itemClicked(var item)

    // 悬停状态（用于 hover 模式的箭头显示）
    property bool hovered: hoverHandler.hovered

    width: parent ? parent.width : 400
    height: carouselHeight
    radius: carouselRadius
    color: EasyTheme.color.card
    clip: true

    // 悬停检测（不拦截事件）
    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            if (hovered) {
                autoPlayTimer.stop()
            } else if (root.autoPlay && root.visible) {
                autoPlayTimer.start()
            }
        }
    }

    // 自动播放定时器（仅在可见且自动播放时运行）
    Timer {
        id: autoPlayTimer
        running: root.autoPlay && root.items.length > 1 && root.visible
        interval: root.interval
        repeat: true
        onTriggered: {
            if (root.items.length > 0) {
                var nextIndex = (root.currentIndex + 1) % root.items.length
                root.goToIndex(nextIndex)
            }
        }
    }

    // 监听可见性变化
    onVisibleChanged: {
        if (!visible) {
            autoPlayTimer.stop()
        } else if (autoPlay && items.length > 1) {
            autoPlayTimer.start()
        }
    }

    // 默认轮播项组件
    Component {
        id: defaultDelegate

        Rectangle {
            id: defaultItem
            width: root.width
            height: root.height
            color: "transparent"

            // 接收从 Loader 传递的数据
            property var modelData: null
            property int index: -1

            // 图片内容
            Image {
                anchors.fill: parent
                source: (defaultItem.modelData && defaultItem.modelData.image) ? defaultItem.modelData.image : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: source !== ""
            }

            // 文字内容（如果有）
            Column {
                anchors.centerIn: parent
                anchors.margins: 20
                spacing: 8
                visible: defaultItem.modelData && (defaultItem.modelData.title || defaultItem.modelData.description)

                Text {
                    text: defaultItem.modelData ? (defaultItem.modelData.title || "") : ""
                    font.pixelSize: 20
                    font.bold: true
                    color: EasyTheme.color.text
                    style: Text.Raised
                    styleColor: "#40000000"
                    visible: defaultItem.modelData && defaultItem.modelData.title
                }

                Text {
                    text: defaultItem.modelData ? (defaultItem.modelData.description || "") : ""
                    font.pixelSize: 14
                    color: EasyTheme.color.text
                    style: Text.Raised
                    styleColor: "#40000000"
                    wrapMode: Text.Wrap
                    width: parent.width - 40
                    horizontalAlignment: Text.AlignHCenter
                    visible: defaultItem.modelData && defaultItem.modelData.description
                }
            }

            // 点击区域
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.itemClicked(defaultItem.modelData)
            }

            // 渐变遮罩（让文字更清晰）
            Rectangle {
                anchors.fill: parent
                visible: defaultItem.modelData && (defaultItem.modelData.title || defaultItem.modelData.description)
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "#20000000"
                    }
                    GradientStop {
                        position: 0.5
                        color: "#40000000"
                    }
                    GradientStop {
                        position: 1.0
                        color: "#60000000"
                    }
                }
            }
        }
    }

    // 轮播内容容器
    Item {
        id: contentContainer
        anchors.fill: parent
        anchors.margins: root.carouselRadius > 0 ? 0 : 0

        // 轮播项滑动容器
        Row {
            id: slideRow
            height: parent.height
            x: -root.currentIndex * root.width

            Behavior on x {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutCubic
                }
            }

            Repeater {
                model: root.items

                delegate: Loader {
                    id: itemLoader
                    width: root.width
                    height: root.height
                    sourceComponent: root.delegate || defaultDelegate

                    // 传递数据到加载的组件
                    onLoaded: {
                        if (item) {
                            item.modelData = modelData
                            item.index = index
                        }
                    }
                }
            }
        }
    }

    // 左箭头
    Rectangle {
        id: leftArrow
        anchors.left: parent.left
        anchors.leftMargin: root.arrowStyle === "outside" ? -40 : 8
        anchors.verticalCenter: parent.verticalCenter
        width: 36
        height: 36
        radius: 18
        color: leftArrowHovered ? EasyTheme.color.primary : "#40000000"
        visible: root.showArrows && root.items.length > 1
                 && (root.arrowStyle === "inside"
                     || root.arrowStyle === "outside"
                     || (root.arrowStyle === "hover" && (leftArrowHovered
                                                         || root.hovered)))

        property bool leftArrowHovered: leftArrowArea.containsMouse

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        EasyIconFont {
            id: leftArrowCanvas
            anchors.centerIn: parent
            icon: EasyIcon.material.chevron_left
            iconSize: 18
            color: "white"
        }

        MouseArea {
            id: leftArrowArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.goToPrev()
        }
    }

    // 右箭头
    Rectangle {
        id: rightArrow
        anchors.right: parent.right
        anchors.rightMargin: root.arrowStyle === "outside" ? -40 : 8
        anchors.verticalCenter: parent.verticalCenter
        width: 36
        height: 36
        radius: 18
        color: rightArrowHovered ? EasyTheme.color.primary : "#40000000"
        visible: root.showArrows && root.items.length > 1
                 && (root.arrowStyle === "inside"
                     || root.arrowStyle === "outside"
                     || (root.arrowStyle === "hover" && (rightArrowHovered
                                                         || root.hovered)))

        property bool rightArrowHovered: rightArrowArea.containsMouse

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
        EasyIconFont {
            id: rightArrowCanvas
            anchors.centerIn: parent
            icon: EasyIcon.material.chevron_right
            iconSize: 18
            color: "white"
        }

        MouseArea {
            id: rightArrowArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.goToNext()
        }
    }


    // 指示器容器
    Row {
        id: indicatorsRow
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: root.indicatorStyle === "bars" ? 4 : 8
        visible: root.showIndicators && root.items.length > 1

        Repeater {
            model: root.items

            delegate: Rectangle {
                id: indicator

                // 根据样式设置大小
                width: {
                    if (root.indicatorStyle === "dots")
                        return index === root.currentIndex ? 24 : 8
                    if (root.indicatorStyle === "bars")
                        return index === root.currentIndex ? 32 : 16
                    if (root.indicatorStyle === "numbers")
                        return 28
                    return 8
                }
                height: {
                    if (root.indicatorStyle === "dots")
                        return 8
                    if (root.indicatorStyle === "bars")
                        return 4
                    if (root.indicatorStyle === "numbers")
                        return 28
                    return 8
                }
                radius: {
                    if (root.indicatorStyle === "dots")
                        return 4
                    if (root.indicatorStyle === "bars")
                        return 2
                    if (root.indicatorStyle === "numbers")
                        return 14
                    return 4
                }

                color: index === root.currentIndex ? EasyTheme.color.primary : "#40000000"
                border.width: root.indicatorStyle === "numbers" ? EasyTheme.size.borderWidthActive : 0
                border.color: "#40ffffff"

                Behavior on width {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                // 数字样式时显示数字
                Text {
                    anchors.centerIn: parent
                    text: String(index + 1)
                    font.pixelSize: 12
                    font.bold: index === root.currentIndex
                    color: index === root.currentIndex ? "white" : "#80ffffff"
                    visible: root.indicatorStyle === "numbers"
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.goToIndex(index)
                }
            }
        }
    }

    // 公开方法：跳转到指定索引
    function goToIndex(index) {
        if (index >= 0 && index < root.items.length) {
            root.currentIndex = index
        }
    }

    // 公开方法：跳转到下一项
    function goToNext() {
        if (root.items.length > 0) {
            var nextIndex = (root.currentIndex + 1) % root.items.length
            root.goToIndex(nextIndex)
        }
    }

    // 公开方法：跳转到上一项
    function goToPrev() {
        if (root.items.length > 0) {
            var prevIndex = (root.currentIndex - 1 + root.items.length) % root.items.length
            root.goToIndex(prevIndex)
        }
    }

    // 公开方法：暂停自动播放
    function pause() {
        autoPlayTimer.stop()
    }

    // 公开方法：恢复自动播放
    function play() {
        if (root.autoPlay) {
            autoPlayTimer.start()
        }
    }
}
