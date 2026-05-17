import QtQuick

Item {
    id: root
    property var sourceItem: null
    property rect sourceRect: Qt.rect(0, 0, 4096, 4096)
    property real radius: 16

    ShaderEffectSource {
        id: sourceProxy
        sourceItem: root.sourceItem
        sourceRect: root.sourceRect.width > 0 ? root.sourceRect : Qt.rect(0, 0, 4096, 4096)
        visible: false
    }

    ShaderEffect {
        id: hBlur
        width: sourceProxy.width
        height: sourceProxy.height
        property var src: sourceProxy
        property real step: 1.0 / width
        property real r: root.radius
        vertexShader: "qrc:/EasyUI/shaders/blur.vert.qsb"
        fragmentShader: "qrc:/EasyUI/shaders/blur_h.frag.qsb"
    }

    ShaderEffect {
        anchors.fill: parent
        property var src: hBlur
        property real step: 1.0 / height
        property real r: root.radius
        vertexShader: "qrc:/EasyUI/shaders/blur.vert.qsb"
        fragmentShader: "qrc:/EasyUI/shaders/blur_v.frag.qsb"
    }
}
