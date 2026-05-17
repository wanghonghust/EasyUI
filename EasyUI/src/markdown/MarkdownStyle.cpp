#include "MarkdownStyle.h"
#include <QJsonObject>
#include <QJsonArray>



MarkdownStyle::MarkdownStyle(QObject *parent) : QObject(parent) {
    m_baseFont = QFont("Segoe UI", 11);
    m_codeFont = QFont("Consolas", 10);
}

QColor MarkdownStyle::backgroundColor() const { return m_backgroundColor; }
QColor MarkdownStyle::textColor() const { return m_textColor; }
QColor MarkdownStyle::codeBackground() const { return m_codeBackground; }
QColor MarkdownStyle::codeTextColor() const { return m_codeTextColor; }
QColor MarkdownStyle::linkColor() const { return m_linkColor; }
QColor MarkdownStyle::blockQuoteColor() const { return m_blockQuoteColor; }
QColor MarkdownStyle::borderColor() const { return m_borderColor; }
QColor MarkdownStyle::tableHeaderBackground() const { return m_tableHeaderBackground; }
QColor MarkdownStyle::tableRowBackground() const { return m_tableRowBackground; }
QColor MarkdownStyle::tableAltRowBackground() const { return m_tableAltRowBackground; }
bool MarkdownStyle::isDark() const { return m_isDark; }

QFont MarkdownStyle::baseFont() const { return m_baseFont; }
QFont MarkdownStyle::codeFont() const { return m_codeFont; }
qreal MarkdownStyle::headingScale() const { return m_headingScale; }

qreal MarkdownStyle::blockSpacing() const { return m_blockSpacing; }
qreal MarkdownStyle::paragraphSpacing() const { return m_paragraphSpacing; }
qreal MarkdownStyle::listIndent() const { return m_listIndent; }

void MarkdownStyle::setBackgroundColor(const QColor &color) {
    if (m_backgroundColor != color) {
        m_backgroundColor = color;
        emit changed();
    }
}
void MarkdownStyle::setTextColor(const QColor &color) {
    if (m_textColor != color) {
        m_textColor = color;
        emit changed();
    }
}
void MarkdownStyle::setCodeBackground(const QColor &color) {
    if (m_codeBackground != color) {
        m_codeBackground = color;
        emit changed();
    }
}
void MarkdownStyle::setCodeTextColor(const QColor &color) {
    if (m_codeTextColor != color) {
        m_codeTextColor = color;
        emit changed();
    }
}
void MarkdownStyle::setLinkColor(const QColor &color) {
    if (m_linkColor != color) {
        m_linkColor = color;
        emit changed();
    }
}
void MarkdownStyle::setBlockQuoteColor(const QColor &color) {
    if (m_blockQuoteColor != color) {
        m_blockQuoteColor = color;
        emit changed();
    }
}
void MarkdownStyle::setBorderColor(const QColor &color) {
    if (m_borderColor != color) {
        m_borderColor = color;
        emit changed();
    }
}
void MarkdownStyle::setTableHeaderBackground(const QColor &color) {
    if (m_tableHeaderBackground != color) {
        m_tableHeaderBackground = color;
        emit changed();
    }
}
void MarkdownStyle::setTableRowBackground(const QColor &color) {
    if (m_tableRowBackground != color) {
        m_tableRowBackground = color;
        emit changed();
    }
}
void MarkdownStyle::setTableAltRowBackground(const QColor &color) {
    if (m_tableAltRowBackground != color) {
        m_tableAltRowBackground = color;
        emit changed();
    }
}
void MarkdownStyle::setIsDark(bool dark) {
    if (m_isDark != dark) {
        m_isDark = dark;
        emit changed();
    }
}

void MarkdownStyle::setBaseFont(const QFont &font) {
    if (m_baseFont != font) {
        m_baseFont = font;
        emit changed();
    }
}
void MarkdownStyle::setCodeFont(const QFont &font) {
    if (m_codeFont != font) {
        m_codeFont = font;
        emit changed();
    }
}
void MarkdownStyle::setHeadingScale(qreal scale) {
    if (!qFuzzyCompare(m_headingScale, scale)) {
        m_headingScale = scale;
        emit changed();
    }
}

void MarkdownStyle::setBlockSpacing(qreal spacing) {
    if (!qFuzzyCompare(m_blockSpacing, spacing)) {
        m_blockSpacing = spacing;
        emit changed();
    }
}
void MarkdownStyle::setParagraphSpacing(qreal spacing) {
    if (!qFuzzyCompare(m_paragraphSpacing, spacing)) {
        m_paragraphSpacing = spacing;
        emit changed();
    }
}
void MarkdownStyle::setListIndent(qreal indent) {
    if (!qFuzzyCompare(m_listIndent, indent)) {
        m_listIndent = indent;
        emit changed();
    }
}

QFont MarkdownStyle::headingFont(int level) const {
    QFont font = m_baseFont;
    font.setBold(true);
    return font;
}

qreal MarkdownStyle::headingSize(int level) const {
    static const qreal sizes[] = {32, 24, 20, 16, 14, 12};
    return sizes[qBound(0, level - 1, 5)] * m_headingScale;
}

void MarkdownStyle::loadFromJson(const QJsonObject &json) {
    if (json.contains("backgroundColor"))
        m_backgroundColor = QColor(json["backgroundColor"].toString());
    if (json.contains("textColor"))
        m_textColor = QColor(json["textColor"].toString());
    if (json.contains("codeBackground"))
        m_codeBackground = QColor(json["codeBackground"].toString());
    if (json.contains("linkColor"))
        m_linkColor = QColor(json["linkColor"].toString());
    if (json.contains("baseFont")) {
        QJsonObject fontObj = json["baseFont"].toObject();
        m_baseFont.setFamily(fontObj["family"].toString());
        m_baseFont.setPointSize(fontObj["size"].toInt());
    }
    emit changed();
}

void MarkdownStyle::resetToDefaults() {
    m_backgroundColor = QColor("#ffffff");
    m_textColor = QColor("#24292e");
    m_codeBackground = QColor("#f6f8fa");
    m_codeTextColor = QColor("#24292e");
    m_linkColor = QColor("#0366d6");
    m_blockQuoteColor = QColor("#6a737d");
    m_borderColor = QColor("#e1e4e8");
    m_tableHeaderBackground = QColor("#f6f8fa");
    m_tableRowBackground = QColor("#ffffff");
    m_tableAltRowBackground = QColor("#f6f8fa");
    m_isDark = false;
    m_baseFont = QFont("Segoe UI", 11);
    m_codeFont = QFont("Consolas", 10);
    m_headingScale = 1.0;
    m_blockSpacing = 16.0;
    m_paragraphSpacing = 8.0;
    m_listIndent = 24.0;
    emit changed();
}

void MarkdownStyle::setDarkMode(bool dark) {
    if (dark == m_isDark) return;  // 避免重复设置

    if (dark) {
        m_backgroundColor = QColor("#00000000");
        m_textColor = QColor("#c9d1d9");
        m_codeBackground = QColor("#161b22");
        m_codeTextColor = QColor("#c9d1d9");
        m_linkColor = QColor("#58a6ff");
        m_blockQuoteColor = QColor("#8b949e");
        m_borderColor = QColor("#30363d");
        m_tableHeaderBackground = QColor("#161b22");
        m_tableRowBackground = QColor("#00000000");
        m_tableAltRowBackground = QColor("#161b22");
        m_isDark = true;
    } else {
        m_backgroundColor = QColor("#00000000");
        m_textColor = QColor("#24292e");
        m_codeBackground = QColor("#f6f8fa");
        m_codeTextColor = QColor("#24292e");
        m_linkColor = QColor("#0366d6");
        m_blockQuoteColor = QColor("#6a737d");
        m_borderColor = QColor("#e1e4e8");
        m_tableHeaderBackground = QColor("#f6f8fa");
        m_tableRowBackground = QColor("#ffffff");
        m_tableAltRowBackground = QColor("#f6f8fa");
        m_isDark = false;
    }
    emit changed();
}

