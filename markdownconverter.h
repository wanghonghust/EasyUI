#ifndef MARKDOWNCONVERTER_H
#define MARKDOWNCONVERTER_H

#include <QString>

class MarkdownConverter
{
public:
    explicit MarkdownConverter();
    ~MarkdownConverter() = default;

    // 设置深色/浅色主题（影响生成的 HTML CSS 颜色）
    void setDarkMode(bool isDark);
    bool isDarkMode() const;

    // 核心转换函数：将 Markdown 文本转换为 HTML
    QString toHtml(const QString &markdown) const;
    
    // 如果你还需要增量渲染，可以保留这个接口
    QString renderIncremental(const QString &fullText, int lastParsedPos) const;

private:
    // 确保 GFM 全局扩展仅注册一次（线程安全）
    static void ensureExtensionsRegistered();

    // 辅助文本处理方法
    QString escapeHtml(const QString &text) const;
    bool needsFullRender(const QString &newChunk) const;
    
    // Qt 显示优化方法
    QString applyInlineStyles(const QString &html) const;
    QString wrapWithHtmlTemplate(const QString &bodyHtml) const;

    bool m_isDark = false;
};

#endif // MARKDOWNCONVERTER_H