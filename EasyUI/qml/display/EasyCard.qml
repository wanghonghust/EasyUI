import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Templates as T
import QtQuick.Effects
import EasyUI

Item {
    id: easyCard

    property real cardWidth: -1
    property real cardHeight: -1
    property int cardPadding: 16
    property int shadowLevel: EasyTheme.elevation.low

    // Back-compat: shadowBlur (px) maps to elevation level
    property int shadowBlur: 8
    property int shadowRadius: 10

    readonly property int _effectiveElevation: {
        if (shadowLevel !== EasyTheme.elevation.low) return shadowLevel
        if (shadowBlur >= 12) return EasyTheme.elevation.medium
        if (shadowBlur >= 6) return EasyTheme.elevation.low
        return EasyTheme.elevation.low
    }

    property real padding: cardPadding
    default property alias children: contentArea.children

    implicitWidth: contentRect.implicitWidth
    implicitHeight: contentRect.implicitHeight
    width: cardWidth > 0 ? cardWidth : implicitWidth
    height: cardHeight > 0 ? cardHeight : implicitHeight

    property bool hovered: hoverHandler.hovered

    // Hover lift
    transform: Translate {
        y: easyCard.hovered ? -2 : 0
        Behavior on y { NumberAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease } }
    }

    // Shadow layer
    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: EasyTheme.color.shadow
        shadowOpacity: easyCard.hovered
            ? EasyTheme.elevation.shadowOpacity(easyCard._effectiveElevation + 1)
            : EasyTheme.elevation.shadowOpacity(easyCard._effectiveElevation)
        shadowBlur: easyCard.hovered ? 1.0 : 0.6
        shadowHorizontalOffset: 0
        shadowVerticalOffset: easyCard.hovered
            ? EasyTheme.elevation.shadowOffsetY(easyCard._effectiveElevation + 1)
            : EasyTheme.elevation.shadowOffsetY(easyCard._effectiveElevation)
    }

    Rectangle {
        id: contentRect
        anchors.fill: parent
        radius: EasyTheme.size.radiusLarge
        color: easyCard.hovered ? EasyTheme.color.hover : EasyTheme.color.card
        border.color: EasyTheme.color.cardBorder
        border.width: EasyTheme.size.borderWidth
        implicitHeight: contentArea.children.length > 0
            ? contentArea.children[0].implicitHeight + 2 * easyCard.padding
            : 2 * easyCard.padding
        implicitWidth: contentArea.children.length > 0
            ? contentArea.children[0].implicitWidth + 2 * easyCard.padding
            : 2 * easyCard.padding

        Behavior on color { ColorAnimation { duration: EasyTheme.transition.normal; easing.type: EasyTheme.transition.ease } }

        HoverHandler {
            id: hoverHandler
        }

        Item {
            id: contentArea
            anchors.fill: parent
            anchors.margins: easyCard.padding
        }
    }
}
