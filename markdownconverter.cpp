#include "markdownconverter.h"
#include <QByteArray>
#include <QRegularExpression>
#include <QDebug>
#include <mutex>

extern "C" {
#include <cmark-gfm.h>
#include <cmark_gfm/cmark-gfm-core-extensions.h>
}

MarkdownConverter::MarkdownConverter()
{
    // 构造时确保扩展已注册
    ensureExtensionsRegistered();
}

void MarkdownConverter::setDarkMode(bool isDark)
{
    m_isDark = isDark;
}

bool MarkdownConverter::isDarkMode() const
{
    return m_isDark;
}

void MarkdownConverter::ensureExtensionsRegistered()
{
    static std::once_flag flag;
    std::call_once(flag, []() {
        cmark_gfm_core_extensions_ensure_registered();
    });
}

QString MarkdownConverter::toHtml(const QString &markdown) const
{
    if (markdown.isEmpty()) {
        return "";
    }

    QByteArray utf8 = markdown.toUtf8();

    // 1. 配置解析器选项
    int options = CMARK_OPT_DEFAULT 
                | CMARK_OPT_GITHUB_PRE_LANG 
                | CMARK_OPT_HARDBREAKS;
                
    cmark_parser *parser = cmark_parser_new(options);
    if (!parser) {
        qWarning() << "Failed to create cmark parser";
        return escapeHtml(markdown);
    }

    // 2. 附加 GFM 扩展
    const char* extension_names[] = {
        "table", "strikethrough", "autolink", "tasklist", "tagfilter"
    };
    
    for (const char* ext_name : extension_names) {
        cmark_syntax_extension *ext = cmark_find_syntax_extension(ext_name);
        if (ext) {
            cmark_parser_attach_syntax_extension(parser, ext);
        } else {
            qWarning() << "Extension not found:" << ext_name;
        }
    }

    // 3. 喂入数据并解析构建 AST 语法树
    cmark_parser_feed(parser, utf8.constData(), utf8.size());
    cmark_node *doc = cmark_parser_finish(parser);

    if (!doc) {
        qWarning() << "Failed to parse markdown";
        cmark_parser_free(parser);
        return escapeHtml(markdown);
    }

    // 4. 渲染为 HTML
    cmark_llist *extensions = cmark_parser_get_syntax_extensions(parser);
    char *html_c_str = cmark_render_html(doc, options, extensions);

    QString resultHtml;
    if (html_c_str) {
        resultHtml = QString::fromUtf8(html_c_str);
        free(html_c_str); // 释放渲染出的 HTML C字符串内存
    } else {
        qWarning() << "Failed to render HTML";
        resultHtml = escapeHtml(markdown);
    }

    // 5. 释放 AST 语法树和解析器（局部变量，自动清理完毕）
    cmark_node_free(doc);
    cmark_parser_free(parser);

    // 6. 后处理：应用 Qt 兼容的内联样式，并包装 HTML 骨架
    resultHtml = applyInlineStyles(resultHtml);
    return wrapWithHtmlTemplate(resultHtml);
}

QString MarkdownConverter::applyInlineStyles(const QString &html) const
{
    QString result = html;

    // 根据主题选取颜色，匹配 EasyUI Theme.qml
    // 表格
    const QString tableBorder  = m_isDark ? "#414243" : "#dcdfe6";
    const QString thBackground = m_isDark ? "#2d2d2d" : "#f5f5f5";
    const QString trBackground = m_isDark ? "#252528" : "#ffffff";
    const QString trAltBackground = m_isDark ? "#1e1e24" : "#fafafa";
    // 代码块 - 使用与卡片相近的颜色
    const QString preBackground  = m_isDark ? "#252528" : "#f5f5f5";
    const QString codeBackground = m_isDark ? "rgba(255,255,255,0.1)" : "rgba(0,0,0,0.06)";
    // 引用
    const QString blockquoteBorder = m_isDark ? "#0078D4" : "#0078D4";
    // 分割线
    const QString headingBorder = m_isDark ? "#414243" : "#dcdfe6";

    // 1. 处理表格
    result.replace(QRegularExpression("<table\\b([^>]*)>"),
        QString("<table\\1 border=\"0\" cellspacing=\"0\" cellpadding=\"0\" style=\"border-collapse: collapse; margin-top: 10px; margin-bottom: 10px; width: 100%; border-radius: 8px; overflow: hidden; border: 1px solid %1;\">").arg(tableBorder));
    result.replace(QRegularExpression("<th\\b([^>]*)>"),
        QString("<th\\1 style=\"background-color: %1; font-weight: 600; border-bottom: 2px solid %2; padding: 10px 14px; text-align: left;\">").arg(thBackground, tableBorder));
    result.replace(QRegularExpression("<td\\b([^>]*)>"),
        QString("<td\\1 style=\"border-bottom: 1px solid %1; padding: 10px 14px;\">").arg(tableBorder));
    result.replace(QRegularExpression("<tr\\b([^>]*)>"),
        QString("<tr\\1 style=\"background-color: %1;\">").arg(trBackground));
    result.replace(QRegularExpression("<tr\\b([^>]*)>\\s*<td"),
        QString("<tr\\1 style=\"background-color: %1;\">").arg(trAltBackground) + "<td");

    // 2. 处理代码块
    result.replace(QRegularExpression("<pre\\b([^>]*)>"),
        QString("<pre\\1 style=\"background-color: %1; padding: 14px; border-radius: 8px; font-family: 'Cascadia Code', 'Fira Code', Consolas, 'Courier New', monospace; white-space: pre-wrap; word-break: break-all; font-size: 13px; margin: 12px 0; border: 1px solid %2;\">").arg(preBackground, tableBorder));
    result.replace(QRegularExpression("<code\\b([^>]*)>"),
        QString("<code\\1 style=\"font-family: 'Cascadia Code', 'Fira Code', Consolas, 'Courier New', monospace; background-color: %1; padding: 2px 6px; border-radius: 4px; font-size: 90%;\">").arg(codeBackground));

    // 3. 处理引用
    result.replace(QRegularExpression("<blockquote\\b([^>]*)>"),
        QString("<blockquote\\1 style=\"color: %1; border-left: 4px solid %2; margin: 12px 0; padding: 8px 16px; background-color: %3; border-radius: 0 8px 8px 0;\">").arg(m_isDark ? "#9aa0b8" : "#606266", blockquoteBorder, m_isDark ? "rgba(0,120,212,0.1)" : "rgba(0,120,212,0.05)"));

    // 4. 处理标题
    result.replace(QRegularExpression("<h1\\b([^>]*)>"),
        QString("<h1\\1 style=\"font-size: 1.6em; font-weight: 600; color: %1; border-bottom: 1px solid %2; padding-bottom: 0.3em; margin-top: 20px; margin-bottom: 12px;\">").arg(m_isDark ? "#e6eaf2" : "#1a1a1a", headingBorder));
    result.replace(QRegularExpression("<h2\\b([^>]*)>"),
        QString("<h2\\1 style=\"font-size: 1.4em; font-weight: 600; color: %1; border-bottom: 1px solid %2; padding-bottom: 0.3em; margin-top: 20px; margin-bottom: 12px;\">").arg(m_isDark ? "#e6eaf2" : "#1a1a1a", headingBorder));
    result.replace(QRegularExpression("<h3\\b([^>]*)>"),
        QString("<h3\\1 style=\"font-size: 1.2em; font-weight: 600; color: %1; margin-top: 16px; margin-bottom: 8px;\">").arg(m_isDark ? "#e6eaf2" : "#1a1a1a"));
    result.replace(QRegularExpression("<h4\\b([^>]*)>"),
        QString("<h4\\1 style=\"font-size: 1.1em; font-weight: 600; color: %1; margin-top: 14px; margin-bottom: 6px;\">").arg(m_isDark ? "#e6eaf2" : "#1a1a1a"));

    // 5. 处理 hr 分割线
    result.replace(QRegularExpression("<hr\\b([^>]*)>"),
        QString("<hr\\1 style=\"border: none; border-top: 1px solid %1; margin: 16px 0;\">").arg(headingBorder));

    // 6. 处理列表缩进
    result.replace(QRegularExpression("<ul\\b([^>]*)>"),
        QString("<ul\\1 style=\"margin: 8px 0; padding-left: 24px;\">"));
    result.replace(QRegularExpression("<ol\\b([^>]*)>"),
        QString("<ol\\1 style=\"margin: 8px 0; padding-left: 24px;\">"));

    return result;
}


QString MarkdownConverter::wrapWithHtmlTemplate(const QString &bodyHtml) const
{
    // 根据主题选取颜色，匹配 EasyUI Theme.qml
    const QString textColor     = m_isDark ? "#e6eaf2" : "#1a1a1a";
    const QString secondaryColor = m_isDark ? "#8b8fa3" : "#606266";
    const QString accentColor   = "#0078D4";
    const QString headingBorder = m_isDark ? "#414243" : "#dcdfe6";
    const QString hrColor       = m_isDark ? "#414243" : "#dcdfe6";
    const QString selectionBg   = m_isDark ? "#0078D4" : "#0078D4";

    return QStringLiteral(R"(<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
body {
    font-family: 'Microsoft YaHei', 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif;
    line-height: 1.7;
    color: %1;
    font-size: 14px;
    margin: 0;
    padding: 12px 16px;
    background: transparent;
    word-wrap: break-word;
}
p { margin: 0 0 12px 0; line-height: 1.7; }
h1, h2, h3, h4, h5, h6 { margin-top: 20px; margin-bottom: 12px; font-weight: 600; line-height: 1.3; }
h1 { font-size: 1.6em; }
h2 { font-size: 1.4em; }
h3 { font-size: 1.2em; }
h4 { font-size: 1.1em; }
a { color: %2; text-decoration: none; }
a:hover { text-decoration: underline; }
hr { border: none; border-top: 1px solid %3; margin: 16px 0; }
ul, ol { margin: 8px 0; padding-left: 24px; }
li { margin: 6px 0; line-height: 1.6; }
strong { font-weight: 600; }
em { font-style: italic; }
code { font-family: 'Cascadia Code', 'Fira Code', Consolas, 'Courier New', monospace; }
::selection { background: %4; color: white; }
img { max-width: 100%; height: auto; border-radius: 6px; margin: 8px 0; }
table { width: 100%; }
</style>
</head>
<body class="markdown-body">
%5
</body>
</html>)")
        .arg(textColor, accentColor, hrColor, selectionBg, bodyHtml);
}

QString MarkdownConverter::escapeHtml(const QString &text) const
{
    QString result = text;
    result.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    return result;
}

// ============== 增量渲染部分 (如果不需要可以删除) ==============
QString MarkdownConverter::renderIncremental(const QString &fullText, int lastParsedPos) const
{
    if (needsFullRender(fullText.mid(lastParsedPos))) {
        return toHtml(fullText);
    }
    return escapeHtml(fullText.mid(lastParsedPos));
}

bool MarkdownConverter::needsFullRender(const QString &newChunk) const
{
    // 触发完整重新渲染的模式，添加 MultilineOption 以处理文本块中的新行特性
    static const QRegularExpression triggers[] = {
        QRegularExpression("```"),              
        QRegularExpression("^#{1,6}\\s", QRegularExpression::MultilineOption),        
        QRegularExpression("^\\s*[-*+]\\s", QRegularExpression::MultilineOption),    
        QRegularExpression("^\\s*\\d+\\.\\s", QRegularExpression::MultilineOption),  
        QRegularExpression("^\\s*\\|", QRegularExpression::MultilineOption),          
        QRegularExpression("^\\s*>", QRegularExpression::MultilineOption),           
        QRegularExpression("\\*\\*?"),          
        QRegularExpression("~~"),               
        QRegularExpression("\\[.*\\]\\("),      
        QRegularExpression("!\\["),             
        QRegularExpression("- \\[[ xX]\\]"),    
        QRegularExpression("https?://"),         
    };

    for (const auto &re : triggers) {
        if (re.match(newChunk).hasMatch()) return true;
    }

    if (newChunk.count("```") % 2 == 1) return true;

    return false;
}

