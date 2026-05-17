#ifndef MARKDOWNSTYLE_H
#define MARKDOWNSTYLE_H

#include <QObject>
#include <QColor>
#include <QFont>
#include <QJsonObject>
#include <QQmlEngine>


class MarkdownStyle : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // 颜色属性
    Q_PROPERTY(QColor backgroundColor READ backgroundColor WRITE setBackgroundColor NOTIFY changed)
    Q_PROPERTY(QColor textColor READ textColor WRITE setTextColor NOTIFY changed)
    Q_PROPERTY(QColor codeBackground READ codeBackground WRITE setCodeBackground NOTIFY changed)
    Q_PROPERTY(QColor codeTextColor READ codeTextColor WRITE setCodeTextColor NOTIFY changed)
    Q_PROPERTY(QColor linkColor READ linkColor WRITE setLinkColor NOTIFY changed)
    Q_PROPERTY(QColor blockQuoteColor READ blockQuoteColor WRITE setBlockQuoteColor NOTIFY changed)
    Q_PROPERTY(QColor borderColor READ borderColor WRITE setBorderColor NOTIFY changed)

    // 表格颜色
    Q_PROPERTY(QColor tableHeaderBackground READ tableHeaderBackground WRITE setTableHeaderBackground NOTIFY changed)
    Q_PROPERTY(QColor tableRowBackground READ tableRowBackground WRITE setTableRowBackground NOTIFY changed)
    Q_PROPERTY(QColor tableAltRowBackground READ tableAltRowBackground WRITE setTableAltRowBackground NOTIFY changed)

    // 深色模式
    Q_PROPERTY(bool isDark READ isDark WRITE setIsDark NOTIFY changed)

    // 字体属性
    Q_PROPERTY(QFont baseFont READ baseFont WRITE setBaseFont NOTIFY changed)
    Q_PROPERTY(QFont codeFont READ codeFont WRITE setCodeFont NOTIFY changed)
    Q_PROPERTY(qreal headingScale READ headingScale WRITE setHeadingScale NOTIFY changed)

    // 间距
    Q_PROPERTY(qreal blockSpacing READ blockSpacing WRITE setBlockSpacing NOTIFY changed)
    Q_PROPERTY(qreal paragraphSpacing READ paragraphSpacing WRITE setParagraphSpacing NOTIFY changed)
    Q_PROPERTY(qreal listIndent READ listIndent WRITE setListIndent NOTIFY changed)

public:
    explicit MarkdownStyle(QObject *parent = nullptr);

    // Getters
    QColor backgroundColor() const;
    QColor textColor() const;
    QColor codeBackground() const;
    QColor codeTextColor() const;
    QColor linkColor() const;
    QColor blockQuoteColor() const;
    QColor borderColor() const;
    QColor tableHeaderBackground() const;
    QColor tableRowBackground() const;
    QColor tableAltRowBackground() const;
    bool isDark() const;

    QFont baseFont() const;
    QFont codeFont() const;
    qreal headingScale() const;

    qreal blockSpacing() const;
    qreal paragraphSpacing() const;
    qreal listIndent() const;

    // Setters
    void setBackgroundColor(const QColor &color);
    void setTextColor(const QColor &color);
    void setCodeBackground(const QColor &color);
    void setCodeTextColor(const QColor &color);
    void setLinkColor(const QColor &color);
    void setBlockQuoteColor(const QColor &color);
    void setBorderColor(const QColor &color);
    void setTableHeaderBackground(const QColor &color);
    void setTableRowBackground(const QColor &color);
    void setTableAltRowBackground(const QColor &color);
    void setIsDark(bool dark);

    void setBaseFont(const QFont &font);
    void setCodeFont(const QFont &font);
    void setHeadingScale(qreal scale);

    void setBlockSpacing(qreal spacing);
    void setParagraphSpacing(qreal spacing);
    void setListIndent(qreal indent);

    Q_INVOKABLE QFont headingFont(int level) const;
    Q_INVOKABLE qreal headingSize(int level) const;
    Q_INVOKABLE void loadFromJson(const QJsonObject &json);
    Q_INVOKABLE void resetToDefaults();
    Q_INVOKABLE void setDarkMode(bool dark);

signals:
    void changed();

private:
    QColor m_backgroundColor = QColor("#ffffff");
    QColor m_textColor = QColor("#24292e");
    QColor m_codeBackground = QColor("#f6f8fa");
    QColor m_codeTextColor = QColor("#24292e");
    QColor m_linkColor = QColor("#0366d6");
    QColor m_blockQuoteColor = QColor("#6a737d");
    QColor m_borderColor = QColor("#e1e4e8");
    QColor m_tableHeaderBackground = QColor("#f6f8fa");
    QColor m_tableRowBackground = QColor("#ffffff");
    QColor m_tableAltRowBackground = QColor("#f6f8fa");
    bool m_isDark = false;

    QFont m_baseFont;
    QFont m_codeFont;
    qreal m_headingScale = 1.0;

    qreal m_blockSpacing = 16.0;
    qreal m_paragraphSpacing = 8.0;
    qreal m_listIndent = 24.0;
};

#endif