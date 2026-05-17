// MarkdownImage.qml - 图片显示与预览组件
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EasyUI

Rectangle {
    id: root

    // 图片数据属性
    property var blockData: null
    property var style: null
    property bool autoWidth: false
    property bool showCaption: true

    // 内部属性
    property string imageUrl: {
        if (blockData && blockData.spans && blockData.spans.length > 0) {
            var span = blockData.spans[0];
            return span.imageUrl || span.linkUrl || "";
        }
        return "";
    }
    property string altText: blockData && blockData.spans && blockData.spans.length > 0 ? blockData.spans[0].text : "Image"
    property string imageReferenceText: buildImageReferenceText()
    property string displayText: imageReferenceText.length > 0 ? imageReferenceText : altText
    property string clickUrl: {
        if (blockData && blockData.spans && blockData.spans.length > 0) {
            var span = blockData.spans[0];
            if (span.imageUrl && span.linkUrl && span.linkUrl !== span.imageUrl) {
                return span.linkUrl;
            }
        }
        return "";
    }
    property string resolvedImageSource: ""
    property bool compatibilityLoading: false
    property bool compatibilityError: false
    property string compatibilityErrorText: ""
    property int imageRequestToken: 0

    property real maxWidth: autoWidth ? 400 : (parent ? parent.width : 400)
    property real maxHeight: 600

    // 计算后的目标尺寸
    property real targetImageWidth: 200
    property real targetImageHeight: 150

    // 计算标题高度
    property int captionHeight: (root.showCaption && root.displayText.length > 0 && root.displayText !== "Image") ? 28 : 0

    // 默认尺寸 - 使用 implicitHeight 让外部可以读取
    width: autoWidth ? targetImageWidth : maxWidth
    implicitWidth: width
    implicitHeight: targetImageHeight + captionHeight
    height: implicitHeight

    color: "transparent"

    // 加载状态
    property bool isLoading: root.compatibilityLoading || imageContainer.status === Image.Loading
    property bool hasError: root.compatibilityError || imageContainer.status === Image.Error

    function isSvgSource(url) {
        if (!url || typeof url !== "string") {
            return false;
        }
        return /^data:image\/svg\+xml/i.test(url)
            || /\.svg(\?|#|$)/i.test(url)
            || /\/svg(\?|#|$)/i.test(url);
    }

    function isUnsupportedRasterSource(url) {
        if (!url || typeof url !== "string") {
            return false;
        }
        return /^data:image\/(webp|avif)/i.test(url)
            || /\.(webp|avif)(\?|#|$)/i.test(url);
    }

    function formatDisplayName(url) {
        if (!url || typeof url !== "string") {
            return "image";
        }
        if (/^data:image\/webp/i.test(url) || /\.webp(\?|#|$)/i.test(url)) {
            return "webp";
        }
        if (/^data:image\/avif/i.test(url) || /\.avif(\?|#|$)/i.test(url)) {
            return "avif";
        }
        return "image";
    }

    function imageFileNameFromSource(url) {
        if (!url || typeof url !== "string" || /^data:/i.test(url)) {
            return "";
        }

        var cleaned = url.replace(/[?#].*$/, "");
        var match = cleaned.match(/([^\\\/]+)$/);
        if (!match || match.length < 2) {
            return "";
        }

        try {
            return decodeURIComponent(match[1]);
        } catch (error) {
            return match[1];
        }
    }

    function buildImageReferenceText() {
        var raw = blockData && blockData.rawText ? String(blockData.rawText).trim() : "";
        if (/^@image:/i.test(raw)) {
            return raw;
        }

        var fileName = imageFileNameFromSource(root.imageUrl);
        if (fileName.length === 0) {
            return "";
        }

        if (/^(file:|qrc:|:\/|[A-Za-z]:[\\/]|\.{1,2}[\\/])/.test(root.imageUrl)
                || !/^[a-z][a-z0-9+.-]*:\/\//i.test(root.imageUrl)) {
            return "@image:" + fileName;
        }

        return "";
    }

    function extractAttribute(tag, name) {
        var match = new RegExp(name + "\\s*=\\s*(['\"])(.*?)\\1", "i").exec(tag);
        return match && match.length > 2 ? match[2] : "";
    }

    function removeAttribute(tag, name) {
        return tag.replace(new RegExp("\\s+" + name + "\\s*=\\s*(['\"]).*?\\1", "gi"), "");
    }

    function convertNestedSvgTag(tag) {
        var attrsMatch = /^<svg\b([^>]*)\/?>(\s*)$/i.exec(tag);
        var attrs = attrsMatch && attrsMatch.length > 1 ? attrsMatch[1] : "";
        var x = extractAttribute(tag, "x");
        var y = extractAttribute(tag, "y");
        var transform = extractAttribute(tag, "transform");
        var transforms = [];
        if (x || y) {
            transforms.push("translate(" + (x || 0) + " " + (y || 0) + ")");
        }
        if (transform) {
            transforms.push(transform);
        }

        attrs = removeAttribute(attrs, "xmlns");
        attrs = removeAttribute(attrs, "version");
        attrs = removeAttribute(attrs, "x");
        attrs = removeAttribute(attrs, "y");
        attrs = removeAttribute(attrs, "width");
        attrs = removeAttribute(attrs, "height");
        attrs = removeAttribute(attrs, "viewBox");
        attrs = removeAttribute(attrs, "transform");

        if (transforms.length > 0) {
            attrs += ' transform="' + transforms.join(" ") + '"';
        }

        if (/\/\s*>$/.test(tag)) {
            return "<g" + attrs + "></g>";
        }
        return "<g" + attrs + ">";
    }

    function sanitizeSvgMarkup(svgText) {
        if (!svgText || svgText.indexOf("<svg") < 0) {
            return svgText;
        }

        var depth = 0;
        return svgText.replace(/<\/?svg\b[^>]*>/gi, function(tag) {
            var isClosing = /^<\//.test(tag);
            if (!isClosing) {
                if (depth === 0) {
                    depth += /\/\s*>$/.test(tag) ? 0 : EasyTheme.size.borderWidth;
                    return tag;
                }
                depth += /\/\s*>$/.test(tag) ? 0 : EasyTheme.size.borderWidth;
                return convertNestedSvgTag(tag);
            }

            depth = Math.max(0, depth - 1);
            return depth === 0 ? tag : "</g>";
        });
    }

    function loadImageSource() {
        root.imageRequestToken += 1;
        var requestToken = root.imageRequestToken;
        root.compatibilityLoading = false;
        root.compatibilityError = false;
        root.compatibilityErrorText = "";

        if (root.imageUrl.length === 0) {
            root.resolvedImageSource = "";
            return;
        }

        if (isUnsupportedRasterSource(root.imageUrl)) {
            root.resolvedImageSource = "";
            root.compatibilityError = true;
            root.compatibilityErrorText = qsTr("Current Qt runtime does not support ")
                                          + formatDisplayName(root.imageUrl).toUpperCase()
                                          + qsTr(" images");
            return;
        }

        if (isSvgSource(root.imageUrl)) {
            root.resolvedImageSource = "";
            root.compatibilityLoading = true;

            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function() {
                if (xhr.readyState !== XMLHttpRequest.DONE || requestToken !== root.imageRequestToken) {
                    return;
                }
                root.compatibilityLoading = false;
                if (xhr.status >= 200 && xhr.status < 300 && xhr.responseText) {
                    var sanitized = sanitizeSvgMarkup(xhr.responseText);
                    root.resolvedImageSource = "data:image/svg+xml;utf8," + encodeURIComponent(sanitized);
                } else {
                    root.compatibilityError = true;
                    root.compatibilityErrorText = qsTr("Failed to load image");
                    root.resolvedImageSource = root.imageUrl;
                }
            };
            xhr.open("GET", root.imageUrl);
            xhr.send();
            return;
        }

        root.resolvedImageSource = root.imageUrl;
    }

    function handlePrimaryAction() {
        if (root.clickUrl.length > 0) {
            Qt.openUrlExternally(root.clickUrl);
        } else if (root.resolvedImageSource.length === 0 && root.imageUrl.length > 0) {
            Qt.openUrlExternally(root.imageUrl);
        } else {
            imagePreviewDialog.open();
        }
    }

    // 图片加载状态变化时调整尺寸
    onImageUrlChanged: loadImageSource()
    Component.onCompleted: loadImageSource()

    // 图片容器
    Image {
        id: imageContainer
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.autoWidth ? root.targetImageWidth : root.width
        height: root.targetImageHeight
        fillMode: Image.PreserveAspectFit
        smooth: true
        cache: true

        source: root.resolvedImageSource

        // 加载完成后计算目标尺寸
        onStatusChanged: {
            if (status === Image.Ready) {
                var sw = sourceSize.width
                var sh = sourceSize.height
                if (sw > 0 && sh > 0) {
                    var aspectRatio = sh / sw
                    var tw = Math.min(sw, root.maxWidth)
                    var th = tw * aspectRatio

                    // 限制最大高度
                    if (th > root.maxHeight) {
                        th = root.maxHeight
                        tw = th / aspectRatio
                    }

                    // 更新目标尺寸（会触发 implicitHeight 更新）
                    root.targetImageWidth = tw
                    root.targetImageHeight = th
                }
            }
        }

        // 加载进度指示
        Rectangle {
            anchors.fill: parent
            color: root.style && root.style.codeBackground ? root.style.codeBackground : "#f6f8fa"
            visible: root.isLoading || root.hasError

            BusyIndicator {
                anchors.centerIn: parent
                running: root.isLoading
                visible: root.isLoading
                width: 32
                height: 32
            }

            Label {
                anchors.centerIn: parent
                width: Math.max(80, parent.width - 24)
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                text: root.hasError
                      ? (root.compatibilityErrorText.length > 0 ? root.compatibilityErrorText : qsTr("Failed to load image"))
                      : ""
                visible: root.hasError
                color: root.style && root.style.textColor ? root.style.textColor : "#24292e"
            }
        }

        // 点击预览 / 跳转
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.handlePrimaryAction()
        }
    }

    // 图片标题（alt text）
    Label {
        id: caption
        anchors.top: imageContainer.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.displayText
        visible: root.showCaption && root.displayText.length > 0 && root.displayText !== "Image"
        font.pixelSize: 12
        color: root.style && root.style.textColor ? root.style.textColor : "#586069"
        opacity: 0.8
    }

    // 图片预览弹窗
    Dialog {
        id: imagePreviewDialog
        modal: true
        padding: 0
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: parent ? Math.min(parent.width - 48, 1280) : 1100
        height: parent ? Math.min(parent.height - 48, 920) : 760
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        function naturalImageWidth() {
            return previewImage.sourceSize.width > 0
                   ? previewImage.sourceSize.width
                   : previewImage.implicitWidth
        }

        function naturalImageHeight() {
            return previewImage.sourceSize.height > 0
                   ? previewImage.sourceSize.height
                   : previewImage.implicitHeight
        }

        function clampScale(value) {
            return Math.max(previewFlick.minScale, Math.min(previewFlick.maxScale, value))
        }

        function centerPreview() {
            previewFlick.contentX = Math.max(0, (previewFlick.contentWidth - previewFlick.width) / 2)
            previewFlick.contentY = Math.max(0, (previewFlick.contentHeight - previewFlick.height) / 2)
        }

        function fitToWindow() {
            var sw = naturalImageWidth()
            var sh = naturalImageHeight()
            if (sw <= 0 || sh <= 0 || previewViewport.width <= 0 || previewViewport.height <= 0)
                return

            var scale = Math.min(previewViewport.width / sw, previewViewport.height / sh)
            previewFlick.scale = clampScale(Math.min(scale, 2.4))
            Qt.callLater(centerPreview)
        }

        function resetToOriginal() {
            previewFlick.scale = 1.0
            Qt.callLater(centerPreview)
        }

        function zoomBy(delta) {
            previewFlick.scale = clampScale(previewFlick.scale + delta)
            Qt.callLater(centerPreview)
        }

        onOpened: Qt.callLater(fitToWindow)

        Overlay.modal: Rectangle {
            color: EasyTheme.color.overlay
        }

        background: Rectangle {
            radius: EasyTheme.size.radius
            color: EasyTheme.color.card
            border.width: EasyTheme.size.borderWidth
            border.color: EasyTheme.color.border
        }

        contentItem: Item {
            anchors.fill: parent

            // ── Header ──
            Item {
                id: headerBar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 52

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 56
                    spacing: 10

                    EasyIconFont {
                        icon: EasyIcon.material.image
                        iconSize: 20
                        color: EasyTheme.color.secondary
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ColumnLayout {
                        spacing: 1
                        Layout.fillWidth: true

                        Label {
                            text: root.displayText || qsTr("图片预览")
                            color: EasyTheme.color.text
                            font.pixelSize: 15
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Label {
                            text: previewImage.status === Image.Ready
                                  ? imagePreviewDialog.naturalImageWidth() + " × " + imagePreviewDialog.naturalImageHeight() + " px"
                                  : (root.imageUrl || "")
                            color: EasyTheme.color.placeholder
                            font.pixelSize: 11
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }
                    }
                }

                Rectangle {
                    id: previewCloseButton
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    width: 36
                    height: 36
                    radius: EasyTheme.size.radius
                    color: closeBtnMA.containsMouse ? EasyTheme.color.hover : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }

                    EasyIconFont {
                        anchors.centerIn: parent
                        icon: EasyIcon.material.close
                        iconSize: 18
                        color: EasyTheme.color.secondary
                    }

                    MouseArea {
                        id: closeBtnMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: imagePreviewDialog.close()
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: EasyTheme.size.borderWidth
                    color: EasyTheme.color.divider
                }
            }

            // ── Stage ──
            Rectangle {
                id: previewStage
                anchors.top: headerBar.bottom
                anchors.bottom: toolbarBar.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 16
                radius: EasyTheme.size.radius
                color: EasyTheme.isDark ? "#0d0d12" : "#f9fafb"
                border.width: EasyTheme.size.borderWidth
                border.color: EasyTheme.color.divider
                clip: true

                Item {
                    id: previewViewport
                    anchors.fill: parent
                    anchors.margins: 12

                    Flickable {
                        id: previewFlick
                        anchors.fill: parent
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        interactive: contentWidth > width || contentHeight > height
                        contentWidth: Math.max(width, previewImage.width + 40)
                        contentHeight: Math.max(height, previewImage.height + 40)

                        property real scale: 1.0
                        property real minScale: 0.15
                        property real maxScale: 8.0

                        Item {
                            width: previewFlick.contentWidth
                            height: previewFlick.contentHeight

                            Rectangle {
                                visible: previewImage.status === Image.Ready
                                width: previewImage.width + 16
                                height: previewImage.height + 16
                                anchors.centerIn: parent
                                radius: 8
                                color: EasyTheme.color.card
                                border.width: EasyTheme.size.borderWidth
                                border.color: EasyTheme.color.border

                                layer.enabled: true
                                layer.effect: EasyShadow { }
                            }

                            Image {
                                id: previewImage
                                anchors.centerIn: parent
                                width: imagePreviewDialog.naturalImageWidth() > 0 ? imagePreviewDialog.naturalImageWidth() * previewFlick.scale : 0
                                height: imagePreviewDialog.naturalImageHeight() > 0 ? imagePreviewDialog.naturalImageHeight() * previewFlick.scale : 0
                                source: root.resolvedImageSource
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                cache: true

                                onStatusChanged: {
                                    if (status === Image.Ready)
                                        Qt.callLater(imagePreviewDialog.fitToWindow)
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            cursorShape: previewFlick.interactive ? Qt.OpenHandCursor : Qt.ArrowCursor
                            onWheel: (wheel) => {
                                imagePreviewDialog.zoomBy(wheel.angleDelta.y > 0 ? 0.12 : -0.12)
                                wheel.accepted = true
                            }
                        }
                    }

                    BusyIndicator {
                        anchors.centerIn: parent
                        running: previewImage.status === Image.Loading
                        visible: running
                        width: 40
                        height: 40
                    }
                }
            }

            // ── Toolbar ──
            Item {
                id: toolbarBar
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 12
                width: toolbarRow.width + 20
                height: 40

                Rectangle {
                    anchors.fill: parent
                    radius: EasyTheme.size.radius
                    color: EasyTheme.isDark ? "#1e1e28" : "#ffffff"
                    border.width: EasyTheme.size.borderWidth
                    border.color: EasyTheme.color.border

                    layer.enabled: true
                    layer.effect: EasyShadow { }
                }

                Row {
                    id: toolbarRow
                    anchors.centerIn: parent
                    spacing: 4
                    height: parent.height

                    // − Zoom out
                    Rectangle {
                        width: 36
                        height: 36
                        radius: EasyTheme.size.radius
                        color: zoomOutArea.containsMouse ? EasyTheme.color.hover : "transparent"
                        opacity: previewImage.status === Image.Ready ? 1.0 : 0.4
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 100 } }

                        EasyIconFont {
                            anchors.centerIn: parent
                            icon: EasyIcon.material.remove
                            iconSize: 18
                            color: EasyTheme.color.text
                        }

                        MouseArea {
                            id: zoomOutArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: previewImage.status === Image.Ready
                            onClicked: imagePreviewDialog.zoomBy(-0.15)
                        }
                    }

                    // Scale badge
                    Rectangle {
                        width: 56
                        height: 32
                        radius: EasyTheme.size.radius
                        color: EasyTheme.isDark ? "#14141a" : "#f0f1f3"
                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            anchors.centerIn: parent
                            text: Math.round(previewFlick.scale * 100) + "%"
                            color: EasyTheme.color.secondary
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }

                    // + Zoom in
                    Rectangle {
                        width: 36
                        height: 36
                        radius: EasyTheme.size.radius
                        color: zoomInArea.containsMouse ? EasyTheme.color.hover : "transparent"
                        opacity: previewImage.status === Image.Ready ? 1.0 : 0.4
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 100 } }

                        EasyIconFont {
                            anchors.centerIn: parent
                            icon: EasyIcon.material.add
                            iconSize: 18
                            color: EasyTheme.color.text
                        }

                        MouseArea {
                            id: zoomInArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: previewImage.status === Image.Ready
                            onClicked: imagePreviewDialog.zoomBy(0.15)
                        }
                    }

                    // Separator
                    Rectangle {
                        width: 1
                        height: 22
                        color: EasyTheme.color.divider
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Fit
                    Rectangle {
                        width: 52
                        height: 36
                        radius: EasyTheme.size.radius
                        color: fitArea.containsMouse ? EasyTheme.color.primaryBg : EasyTheme.color.primary
                        opacity: previewImage.status === Image.Ready ? 1.0 : 0.4
                        anchors.verticalCenter: parent.verticalCenter
                        border.width: EasyTheme.size.borderWidth
                        border.color: fitArea.containsMouse ? EasyTheme.color.primaryBorder : EasyTheme.color.primary
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Label {
                            anchors.centerIn: parent
                            text: qsTr("适应")
                            color: fitArea.containsMouse ? EasyTheme.color.primary : "#ffffff"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            id: fitArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: previewImage.status === Image.Ready
                            onClicked: imagePreviewDialog.fitToWindow()
                        }
                    }

                    // 1:1
                    Rectangle {
                        width: 44
                        height: 36
                        radius: EasyTheme.size.radius
                        color: originalArea.containsMouse ? EasyTheme.color.hover : "transparent"
                        opacity: previewImage.status === Image.Ready ? 1.0 : 0.4
                        anchors.verticalCenter: parent.verticalCenter
                        border.width: EasyTheme.size.borderWidth
                        border.color: EasyTheme.color.border
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Label {
                            anchors.centerIn: parent
                            text: "1:1"
                            color: EasyTheme.color.text
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            id: originalArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: previewImage.status === Image.Ready
                            onClicked: imagePreviewDialog.resetToOriginal()
                        }
                    }

                    // Separator
                    Rectangle {
                        width: 1
                        height: 22
                        color: EasyTheme.color.divider
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Open external
                    Rectangle {
                        width: 64
                        height: 36
                        radius: EasyTheme.size.radius
                        color: openArea.containsMouse ? EasyTheme.color.hover : "transparent"
                        opacity: root.imageUrl.length > 0 ? 1.0 : 0.4
                        anchors.verticalCenter: parent.verticalCenter
                        border.width: EasyTheme.size.borderWidth
                        border.color: EasyTheme.color.border
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Row {
                            anchors.centerIn: parent
                            spacing: 4

                            EasyIconFont {
                                icon: EasyIcon.material.open_in_new
                                iconSize: 14
                                color: EasyTheme.color.text
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: qsTr("原图")
                                color: EasyTheme.color.text
                                font.pixelSize: 12
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: openArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: root.imageUrl.length > 0
                            onClicked: Qt.openUrlExternally(root.imageUrl)
                        }
                    }
                }
            }
        }
    }

    // 悬停效果
    Rectangle {
        anchors.fill: imageContainer
        color: "transparent"
        border.color: imageMouseArea.containsMouse && root.style && root.style.linkColor ? root.style.linkColor : "transparent"
        border.width: 2
        opacity: 0.5
    }

    // 悬停检测
    MouseArea {
        id: imageMouseArea
        anchors.fill: imageContainer
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.handlePrimaryAction()
    }
}
