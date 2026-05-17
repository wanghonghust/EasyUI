#ifndef MARKDOWN_CODEHIGHLIGHTER_H
#define MARKDOWN_CODEHIGHLIGHTER_H

#include <QColor>
#include <QQuickTextDocument>
#include <QRegularExpression>
#include <QSyntaxHighlighter>
#include <QTextCharFormat>


class CodeHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT
    // QML 传入 TextArea.textDocument（实际类型为 QQuickTextDocument*）
    Q_PROPERTY(QQuickTextDocument * textDocument READ textDocument WRITE setTextDocument NOTIFY textDocumentChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QString theme READ theme WRITE setTheme NOTIFY themeChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

public:
    explicit CodeHighlighter(QObject *parent = nullptr);
    ~CodeHighlighter() override;

    QQuickTextDocument * textDocument() const;
    void setTextDocument(QQuickTextDocument *doc);

    QString language() const;
    void setLanguage(const QString &lang);

    QString theme() const;
    void setTheme(const QString &theme);

    bool enabled() const;
    void setEnabled(bool enabled);

signals:
    void textDocumentChanged();
    void languageChanged();
    void themeChanged();
    void enabledChanged();

protected:
    void highlightBlock(const QString &text) override;

private:
    struct HighlightRule {
        QRegularExpression pattern;
        QTextCharFormat format;
    };

    struct ThemePalette {
        QColor keyword;
        QColor typeName;
        QColor functionName;
        QColor stringLiteral;
        QColor number;
        QColor comment;
        QColor preprocessor;
        QColor property;
        QColor id;
        QColor signal;
    };

    void rebuildRules();
    void setupCppRules();
    void setupQmlRules();
    void setupPythonRules();
    void setupJavaScriptRules();
    void setupGenericRules();
    QTextCharFormat makeFormat(const QColor &color, bool bold = false, bool italic = false) const;
    ThemePalette currentPalette() const;

    QVector<HighlightRule> m_rules;
    QString m_language;
    QString m_theme = "onedark";
    bool m_enabled = true;
    QQuickTextDocument *m_quickDoc = nullptr;

    enum BlockState {
        NormalState = -1,
        InComment = 1
    };
};

#endif // MARKDOWN_CODEHIGHLIGHTER_H