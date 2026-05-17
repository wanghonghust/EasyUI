#include "codehighlighter.h"

#include <QFont>
#include <QQuickTextDocument>
#include <QTextDocument>



CodeHighlighter::CodeHighlighter(QObject *parent)
    : QSyntaxHighlighter(parent)
{
    rebuildRules();
}

CodeHighlighter::~CodeHighlighter() = default;

QQuickTextDocument * CodeHighlighter::textDocument() const
{
    return m_quickDoc;
}

void CodeHighlighter::setTextDocument(QQuickTextDocument *doc)
{
    if (m_quickDoc == doc)
        return;

    m_quickDoc = doc;

    QTextDocument *textDoc = nullptr;
    if (m_quickDoc) {
        textDoc = m_quickDoc->textDocument();
    } else {
        textDoc = qobject_cast<QTextDocument*>(doc);
    }

    setDocument(textDoc);
    emit textDocumentChanged();
}

QString CodeHighlighter::language() const
{
    return m_language;
}

void CodeHighlighter::setLanguage(const QString &lang)
{
    const QString normalized = lang.trimmed().toLower();
    if (m_language == normalized)
        return;

    m_language = normalized;
    rebuildRules();
    rehighlight();
    emit languageChanged();
}

QString CodeHighlighter::theme() const
{
    return m_theme;
}

void CodeHighlighter::setTheme(const QString &theme)
{
    QString normalized = theme.trimmed().toLower();
    if (normalized != QStringLiteral("onelight"))
        normalized = QStringLiteral("onedark");

    if (m_theme == normalized)
        return;

    m_theme = normalized;
    rebuildRules();
    rehighlight();
    emit themeChanged();
}

bool CodeHighlighter::enabled() const
{
    return m_enabled;
}

void CodeHighlighter::setEnabled(bool enabled)
{
    if (m_enabled == enabled)
        return;

    m_enabled = enabled;
    setDocument(enabled ? (m_quickDoc ? m_quickDoc->textDocument() : nullptr) : nullptr);

    if (enabled)
        rehighlight();

    emit enabledChanged();
}

QTextCharFormat CodeHighlighter::makeFormat(const QColor &color, bool bold, bool italic) const
{
    QTextCharFormat format;
    format.setForeground(color);
    format.setFontWeight(bold ? QFont::Bold : QFont::Normal);
    format.setFontItalic(italic);
    return format;
}

CodeHighlighter::ThemePalette CodeHighlighter::currentPalette() const
{
    if (m_theme == QStringLiteral("onelight")) {
        return {
            QColor(QStringLiteral("#A626A4")), // keyword
            QColor(QStringLiteral("#C18401")), // typeName
            QColor(QStringLiteral("#4078F2")), // functionName
            QColor(QStringLiteral("#50A14F")), // stringLiteral
            QColor(QStringLiteral("#986801")), // number
            QColor(QStringLiteral("#A0A1A7")), // comment
            QColor(QStringLiteral("#0184BC")), // preprocessor
            QColor(QStringLiteral("#E45649")), // property
            QColor(QStringLiteral("#526FFF")), // id
            QColor(QStringLiteral("#0184BC"))  // signal
        };
    }

    return {
        QColor(QStringLiteral("#C678DD")), // keyword
        QColor(QStringLiteral("#E5C07B")), // typeName
        QColor(QStringLiteral("#61AFEF")), // functionName
        QColor(QStringLiteral("#98C379")), // stringLiteral
        QColor(QStringLiteral("#D19A66")), // number
        QColor(QStringLiteral("#5C6370")), // comment
        QColor(QStringLiteral("#56B6C2")), // preprocessor
        QColor(QStringLiteral("#E06C75")), // property
        QColor(QStringLiteral("#61AFEF")), // id
        QColor(QStringLiteral("#56B6C2"))  // signal
    };
}

void CodeHighlighter::rebuildRules()
{
    m_rules.clear();

    if (m_language == QStringLiteral("cpp") ||
        m_language == QStringLiteral("c") ||
        m_language == QStringLiteral("h") ||
        m_language == QStringLiteral("hpp") ||
        m_language == QStringLiteral("cc") ||
        m_language == QStringLiteral("cxx")) {
        setupCppRules();
    } else if (m_language == QStringLiteral("qml")) {
        setupQmlRules();
    } else if (m_language == QStringLiteral("python") || m_language == QStringLiteral("py")) {
        setupPythonRules();
    } else if (m_language == QStringLiteral("javascript") ||
               m_language == QStringLiteral("js") ||
               m_language == QStringLiteral("typescript") ||
               m_language == QStringLiteral("ts") ||
               m_language == QStringLiteral("json")) {
        setupJavaScriptRules();
    } else {
        setupGenericRules();
    }
}

// ==================== 语法规则 ====================

void CodeHighlighter::setupCppRules()
{
    const ThemePalette palette = currentPalette();
    HighlightRule rule;

    const QStringList keywords = {
        QStringLiteral("alignas"), QStringLiteral("alignof"), QStringLiteral("and"), QStringLiteral("and_eq"), QStringLiteral("asm"),
        QStringLiteral("auto"), QStringLiteral("bitand"), QStringLiteral("bitor"), QStringLiteral("bool"), QStringLiteral("break"),
        QStringLiteral("case"), QStringLiteral("catch"), QStringLiteral("char"), QStringLiteral("char8_t"), QStringLiteral("char16_t"),
        QStringLiteral("char32_t"), QStringLiteral("class"), QStringLiteral("compl"), QStringLiteral("concept"), QStringLiteral("const"),
        QStringLiteral("consteval"), QStringLiteral("constexpr"), QStringLiteral("constinit"), QStringLiteral("const_cast"), QStringLiteral("continue"),
        QStringLiteral("co_await"), QStringLiteral("co_return"), QStringLiteral("co_yield"), QStringLiteral("decltype"), QStringLiteral("default"),
        QStringLiteral("delete"), QStringLiteral("do"), QStringLiteral("double"), QStringLiteral("dynamic_cast"), QStringLiteral("else"),
        QStringLiteral("enum"), QStringLiteral("explicit"), QStringLiteral("export"), QStringLiteral("extern"), QStringLiteral("false"),
        QStringLiteral("float"), QStringLiteral("for"), QStringLiteral("friend"), QStringLiteral("goto"), QStringLiteral("if"),
        QStringLiteral("inline"), QStringLiteral("int"), QStringLiteral("long"), QStringLiteral("mutable"), QStringLiteral("namespace"),
        QStringLiteral("new"), QStringLiteral("noexcept"), QStringLiteral("not"), QStringLiteral("not_eq"), QStringLiteral("nullptr"),
        QStringLiteral("operator"), QStringLiteral("or"), QStringLiteral("or_eq"), QStringLiteral("private"), QStringLiteral("protected"),
        QStringLiteral("public"), QStringLiteral("register"), QStringLiteral("reinterpret_cast"), QStringLiteral("requires"), QStringLiteral("return"),
        QStringLiteral("short"), QStringLiteral("signed"), QStringLiteral("sizeof"), QStringLiteral("static"), QStringLiteral("static_assert"),
        QStringLiteral("static_cast"), QStringLiteral("struct"), QStringLiteral("switch"), QStringLiteral("template"), QStringLiteral("this"),
        QStringLiteral("thread_local"), QStringLiteral("throw"), QStringLiteral("true"), QStringLiteral("try"), QStringLiteral("typedef"),
        QStringLiteral("typeid"), QStringLiteral("typename"), QStringLiteral("union"), QStringLiteral("unsigned"), QStringLiteral("using"),
        QStringLiteral("virtual"), QStringLiteral("void"), QStringLiteral("volatile"), QStringLiteral("wchar_t"), QStringLiteral("while"),
        QStringLiteral("xor"), QStringLiteral("xor_eq"), QStringLiteral("override"), QStringLiteral("final"), QStringLiteral("emit"),
        QStringLiteral("signals"), QStringLiteral("slots"), QStringLiteral("Q_OBJECT"), QStringLiteral("Q_PROPERTY"), QStringLiteral("Q_INVOKABLE")
    };

    const QTextCharFormat keywordFormat = makeFormat(palette.keyword, true);
    for (const QString &kw : keywords) {
        rule.pattern = QRegularExpression(QStringLiteral("\\b%1\\b").arg(QRegularExpression::escape(kw)));
        rule.format = keywordFormat;
        m_rules.append(rule);
    }

    rule.pattern = QRegularExpression(QStringLiteral("\\b[A-Z][A-Za-z0-9_]*\\b"));
    rule.format = makeFormat(palette.typeName);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("\\b[A-Za-z_][A-Za-z0-9_]*(?=\\s*\\()"));
    rule.format = makeFormat(palette.functionName);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("\"(?:\\\\.|[^\"\\\\])*\""));
    rule.format = makeFormat(palette.stringLiteral);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("'(?:\\\\.|[^'\\\\])*'"));
    rule.format = makeFormat(palette.stringLiteral);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("\\b0[xX][0-9a-fA-F]+\\b"));
    rule.format = makeFormat(palette.number);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("\\b[0-9]+(\\.[0-9]+)?([eE][+-]?[0-9]+)?\\b"));
    rule.format = makeFormat(palette.number);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("//[^\n]*"));
    rule.format = makeFormat(palette.comment, false, true);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("^\\s*#[^\n]*"));
    rule.format = makeFormat(palette.preprocessor);
    m_rules.append(rule);
}

void CodeHighlighter::setupQmlRules()
{
    const ThemePalette palette = currentPalette();
    HighlightRule rule;

    const QStringList keywords = {
        QStringLiteral("import"), QStringLiteral("as"), QStringLiteral("pragma"), QStringLiteral("property"), QStringLiteral("alias"),
        QStringLiteral("signal"), QStringLiteral("function"), QStringLiteral("required"), QStringLiteral("readonly"),
        QStringLiteral("default"), QStringLiteral("bool"), QStringLiteral("double"), QStringLiteral("int"), QStringLiteral("real"),
        QStringLiteral("string"), QStringLiteral("url"), QStringLiteral("color"), QStringLiteral("date"), QStringLiteral("var"),
        QStringLiteral("let"), QStringLiteral("const"), QStringLiteral("if"), QStringLiteral("else"), QStringLiteral("for"),
        QStringLiteral("while"), QStringLiteral("do"), QStringLiteral("switch"), QStringLiteral("case"), QStringLiteral("break"),
        QStringLiteral("continue"), QStringLiteral("return"), QStringLiteral("try"), QStringLiteral("catch"), QStringLiteral("throw"),
        QStringLiteral("true"), QStringLiteral("false"), QStringLiteral("null"), QStringLiteral("undefined"), QStringLiteral("Component"),
        QStringLiteral("anchors"), QStringLiteral("parent")
    };

    const QTextCharFormat keywordFormat = makeFormat(palette.keyword, true);
    for (const QString &kw : keywords) {
        rule.pattern = QRegularExpression(QStringLiteral("\\b%1\\b").arg(QRegularExpression::escape(kw)));
        rule.format = keywordFormat;
        m_rules.append(rule);
    }

    rule.pattern = QRegularExpression(QStringLiteral("\\b[A-Z][A-Za-z0-9_]*\\b"));
    rule.format = makeFormat(palette.typeName);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("\\bid\\s*:\\s*[A-Za-z_][A-Za-z0-9_]*"));
    rule.format = makeFormat(palette.id, false, true);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("\\b[a-z][A-Za-z0-9_]*\\s*:"));
    rule.format = makeFormat(palette.property);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("\"(?:\\\\.|[^\"\\\\])*\""));
    rule.format = makeFormat(palette.stringLiteral);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("`(?:\\\\.|[^`\\\\])*`"));
    rule.format = makeFormat(palette.stringLiteral);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("\\bon[A-Z][A-Za-z0-9_]*\\s*:"));
    rule.format = makeFormat(palette.signal, true);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("\\b[A-Za-z_][A-Za-z0-9_]*(?=\\s*\\()"));
    rule.format = makeFormat(palette.functionName);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("\\b[0-9]+(\\.[0-9]+)?\\b"));
    rule.format = makeFormat(palette.number);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("//[^\n]*"));
    rule.format = makeFormat(palette.comment, false, true);
    m_rules.append(rule);
}

void CodeHighlighter::setupPythonRules()
{
    const ThemePalette palette = currentPalette();
    HighlightRule rule;

    const QStringList keywords = {
        QStringLiteral("False"), QStringLiteral("None"), QStringLiteral("True"), QStringLiteral("and"), QStringLiteral("as"),
        QStringLiteral("assert"), QStringLiteral("async"), QStringLiteral("await"), QStringLiteral("break"), QStringLiteral("class"),
        QStringLiteral("continue"), QStringLiteral("def"), QStringLiteral("del"), QStringLiteral("elif"), QStringLiteral("else"),
        QStringLiteral("except"), QStringLiteral("finally"), QStringLiteral("for"), QStringLiteral("from"), QStringLiteral("global"),
        QStringLiteral("if"), QStringLiteral("import"), QStringLiteral("in"), QStringLiteral("is"), QStringLiteral("lambda"),
        QStringLiteral("nonlocal"), QStringLiteral("not"), QStringLiteral("or"), QStringLiteral("pass"), QStringLiteral("raise"),
        QStringLiteral("return"), QStringLiteral("try"), QStringLiteral("while"), QStringLiteral("with"), QStringLiteral("yield")
    };

    const QTextCharFormat keywordFormat = makeFormat(palette.keyword, true);
    for (const QString &kw : keywords) {
        rule.pattern = QRegularExpression(QStringLiteral("\\b%1\\b").arg(QRegularExpression::escape(kw)));
        rule.format = keywordFormat;
        m_rules.append(rule);
    }

    rule.pattern = QRegularExpression(QStringLiteral("^\\s*@[A-Za-z_][A-Za-z0-9_]*"));
    rule.format = makeFormat(palette.preprocessor);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("\\bdef\\s+[A-Za-z_][A-Za-z0-9_]*"));
    rule.format = makeFormat(palette.functionName);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("\\bclass\\s+[A-Za-z_][A-Za-z0-9_]*"));
    rule.format = makeFormat(palette.typeName);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("\"\"\".*\"\"\""));
    rule.format = makeFormat(palette.stringLiteral);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("'''.*'''"));
    rule.format = makeFormat(palette.stringLiteral);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("\"(?:\\\\.|[^\"\\\\])*\""));
    rule.format = makeFormat(palette.stringLiteral);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("'(?:\\\\.|[^'\\\\])*'"));
    rule.format = makeFormat(palette.stringLiteral);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("\\b[0-9]+(\\.[0-9]+)?([eE][+-]?[0-9]+)?\\b"));
    rule.format = makeFormat(palette.number);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("#[^\n]*"));
    rule.format = makeFormat(palette.comment, false, true);
    m_rules.append(rule);
}

void CodeHighlighter::setupJavaScriptRules()
{
    setupQmlRules();
}

void CodeHighlighter::setupGenericRules()
{
    const ThemePalette palette = currentPalette();
    HighlightRule rule;

    rule.pattern = QRegularExpression(QStringLiteral("\"(?:\\\\.|[^\"\\\\])*\""));
    rule.format = makeFormat(palette.stringLiteral);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("'(?:\\\\.|[^'\\\\])*'"));
    rule.format = makeFormat(palette.stringLiteral);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("\\b[0-9]+(\\.[0-9]+)?([eE][+-]?[0-9]+)?\\b"));
    rule.format = makeFormat(palette.number);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("//[^\n]*"));
    rule.format = makeFormat(palette.comment, false, true);
    m_rules.append(rule);

    rule.pattern = QRegularExpression(QStringLiteral("#[^\n]*"));
    rule.format = makeFormat(palette.comment, false, true);
    m_rules.append(rule);
}

void CodeHighlighter::highlightBlock(const QString &text)
{
    if (!m_enabled)
        return;

    for (const HighlightRule &rule : m_rules) {
        QRegularExpressionMatchIterator matchIterator = rule.pattern.globalMatch(text);
        while (matchIterator.hasNext()) {
            const QRegularExpressionMatch match = matchIterator.next();
            setFormat(match.capturedStart(), match.capturedLength(), rule.format);
        }
    }

    const bool supportsBlockComments =
        m_language == QStringLiteral("cpp") ||
        m_language == QStringLiteral("c") ||
        m_language == QStringLiteral("h") ||
        m_language == QStringLiteral("hpp") ||
        m_language == QStringLiteral("cc") ||
        m_language == QStringLiteral("cxx") ||
        m_language == QStringLiteral("javascript") ||
        m_language == QStringLiteral("js") ||
        m_language == QStringLiteral("typescript") ||
        m_language == QStringLiteral("ts") ||
        m_language == QStringLiteral("qml");

    if (!supportsBlockComments)
        return;

    setCurrentBlockState(NormalState);

    int startIndex = previousBlockState() == InComment
        ? 0
        : text.indexOf(QStringLiteral("/*"));

    const QTextCharFormat commentFormat = makeFormat(currentPalette().comment, false, true);

    while (startIndex >= 0) {
        const int endIndex = text.indexOf(QStringLiteral("*/"), startIndex);
        int commentLength = 0;

        if (endIndex == -1) {
            setCurrentBlockState(InComment);
            commentLength = text.length() - startIndex;
        } else {
            commentLength = endIndex - startIndex + 2;
        }

        setFormat(startIndex, commentLength, commentFormat);

        if (endIndex == -1)
            break;

        startIndex = text.indexOf(QStringLiteral("/*"), startIndex + commentLength);
    }
}

