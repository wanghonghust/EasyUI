#include "MarkdownDocument.h"
#include "MarkdownParser.h"
#include "MarkdownStyle.h"
#include <QClipboard>
#include <QGuiApplication>
#include <QDebug>
#include <QFontMetrics>


// 预编译的字体大小表（用于宽度估算）
static const int headingSizes[] = {32, 24, 20, 16, 14, 12};

QVariantList Block::getSpansVariant() const {
    QVariantList list;
    for (const auto &span : spans) {
        QVariantMap map;
        map["text"] = span.text;
        map["bold"] = span.bold;
        map["italic"] = span.italic;
        map["code"] = span.code;
        map["strikethrough"] = span.strikethrough;
        map["linkUrl"] = span.linkUrl;
        map["imageUrl"] = span.imageUrl;
        list.append(map);
    }
    return list;
}

QVariantList Block::getChildrenVariant() const {
    QVariantList list;
    for (const auto &child : children) {
        QVariantMap map;
        map["type"] = static_cast<int>(child.type);
        map["spans"] = child.getSpansVariant();
        map["language"] = child.language;
        map["rawText"] = child.rawText;
        map["level"] = child.level;
        map["isTask"] = child.isTask;
        map["taskChecked"] = child.taskChecked;
        map["estimatedWidth"] = child.estimatedWidth;
        list.append(map);
    }
    return list;
}

QString Block::toHtml(const MarkdownStyle *style) const {
    QString html;
    QString codeBg = style ? style->codeBackground().name() : "#f6f8fa";
    QString codeColor = style ? style->codeTextColor().name() : "#24292e";
    QString linkColor = style ? style->linkColor().name() : "#0366d6";

    for (const auto &span : spans) {
        QString content = span.text;
        // 转义 HTML
        content.replace('&', "&amp;")
               .replace('<', "&lt;")
               .replace('>', "&gt;");

        if (span.code) {
            html += QString("<span style=\"background-color:%1;padding:2px 4px;border-radius:3px;font-family:Consolas,monospace;color:%2;\">%3</span>")
                    .arg(codeBg).arg(codeColor).arg(content);
        } else if (!span.linkUrl.isEmpty()) {
            html += QString("<a href=\"%1\" style=\"color:%2;text-decoration:underline;\">%3</a>")
                    .arg(span.linkUrl).arg(linkColor).arg(content);
        } else {
            QString styleStr;
            if (span.bold) styleStr += "font-weight:bold;";
            if (span.italic) styleStr += "font-style:italic;";
            if (span.strikethrough) styleStr += "text-decoration:line-through;";
            if (!styleStr.isEmpty()) {
                html += QString("<span style=\"%1\">%2</span>").arg(styleStr).arg(content);
            } else {
                html += content;
            }
        }
    }
    return html;
}

MarkdownDocument::MarkdownDocument(QObject *parent)
    : QObject(parent)
    , m_parser(new MarkdownParser(this))
{
    QObject::connect(m_parser, &MarkdownParser::parsingFinished,
                     this, [this](const QList<Block> &blocks) {
        m_blocks = blocks;
        m_lastBlocks = blocks;
        m_lastSource = m_source;
        calculateEstimatedWidths(m_blocks);  // 预计算宽度
        m_loading = false;
        emit loadingChanged();
        emit blocksChanged();
    });
}

// 预计算每个 block 的估计宽度（使用默认字体）
void MarkdownDocument::calculateEstimatedWidths(QList<Block> &blocks) {
    // 使用默认字体进行估算
    QFont baseFont("Segoe UI", 14);
    QFont codeFont("Consolas", 12);

    for (auto &block : blocks) {
        block.estimatedWidth = estimateBlockWidth(block, baseFont, codeFont);
    }
}

// 估算单个 block 的宽度
int MarkdownDocument::estimateBlockWidth(const Block &block, const QFont &baseFont, const QFont &codeFont) {
    QFontMetrics fm(baseFont);
    QFontMetrics codeFm(codeFont);

    int width = 0;
    int type = static_cast<int>(block.type);

    // Heading: 根据级别使用不同字体大小
    if (type >= 2 && type <= 7) {
        int level = type - 1;  // type=2 -> level=1
        int idx = qMax(0, qMin(level - 1, 5));
        QFont headingFont("Segoe UI", headingSizes[idx]);
        headingFont.setBold(true);
        QFontMetrics headingFm(headingFont);

        QString text;
        for (const auto &span : block.spans) {
            text += span.text;
        }
        width = headingFm.horizontalAdvance(text);
    }
    // CodeBlock: 使用代码字体
    else if (type == 8) {
        if (!block.spans.isEmpty()) {
            QString code = block.spans.first().text;
            // 代码块需要额外空间（padding + border）
            width = codeFm.horizontalAdvance(code) + 40;
        }
    }
    // BlockQuote: 普通字体 + 额外空间
    else if (type == 9) {
        QString text;
        for (const auto &span : block.spans) {
            text += span.text;
        }
        width = fm.horizontalAdvance(text) + 40;  // 左边距 + padding
    }
    // ListItem: 标记 + 内容
    else if (type >= 10 && type <= 12) {
        QString marker = (type == 10) ? "• " : QString("%1. ").arg(block.level);
        QString text;
        for (const auto &span : block.spans) {
            text += span.text;
        }
        width = fm.horizontalAdvance(marker + text) + block.level * 24;  // 缩进
    }
    // Table: 简单估算
    else if (type == 14) {
        width = 200;  // 表格宽度复杂，使用默认值
    }
    // HorizontalRule: 固定宽度
    else if (type == 13) {
        width = 60;
    }
    // HtmlBlock: HTML rendered as rich text
    else if (type == 17) {
        width = 200;
    }
    // Paragraph: 普通文本
    else {
        QString text;
        for (const auto &span : block.spans) {
            text += span.text;
            // 行内代码额外空间
            if (span.code) {
                width += 8;  // padding
            }
        }
        width = fm.horizontalAdvance(text);
    }

    return qMax(60, width);  // 最小宽度 60
}

QString MarkdownDocument::source() const { return m_source; }

void MarkdownDocument::setSource(const QString &source) {
    if (m_source == source) return;
    m_source = source;
    emit sourceChanged();

    if (m_source.isEmpty()) {
        m_blocks.clear();
        m_lastBlocks.clear();
        m_lastSource.clear();
        emit blocksChanged();
        return;
    }

    // 尝试增量更新
    if (parseIncremental()) {
        return;
    }

    // 全量解析
    m_loading = true;
    emit loadingChanged();
    m_parser->parseAsync(m_source);
}

bool MarkdownDocument::parseIncremental() {
    // 快速路径：如果新文本是旧文本的追加，且结构没变，只更新最后一个 block
    if (m_lastSource.isEmpty() || m_lastBlocks.isEmpty()) {
        return false;
    }

    // 检查是否是纯追加（新文本以旧文本开头）
    if (!m_source.startsWith(m_lastSource)) {
        return false;
    }

    QString added = m_source.mid(m_lastSource.length());

    // 如果追加的内容包含会改变 block 结构的标记，需要全量解析
    static const QRegularExpression structChangeRe("^\\s*(#{1,6}\\s|```|\\s*[-*+\\d]\\.\\s|\\s*[-*_]{3,}\\s*$|\\s*>\\s*|\\|)");
    if (structChangeRe.match(added).hasMatch()) {
        return false;
    }

    // 检查追加内容是否会导致最后一个 block 的类型变化
    if (added.contains('\n')) {
        QStringList addedLines = added.split('\n');
        for (const QString &line : addedLines) {
            QString trimmed = line.trimmed();
            if (trimmed.isEmpty()) continue;
            if (trimmed.startsWith('#') || trimmed.startsWith("```") ||
                trimmed.startsWith("-") || trimmed.startsWith("*") || trimmed.startsWith("+") ||
                QRegularExpression("^\\d+\\.").match(trimmed).hasMatch() ||
                trimmed.startsWith(">")) {
                return false;
            }
        }
    }

    // 可以增量更新：只更新最后一个 block
    int lastIdx = m_lastBlocks.size() - 1;
    Block &lastBlock = m_lastBlocks[lastIdx];

    // 更新 rawText
    lastBlock.rawText += added;

    // 重新解析最后一个 block 的 spans（直接拼接文本后解析 inline）
    QString text = lastBlock.rawText;
    // 对于段落，去掉换行符再解析
    if (lastBlock.type == BlockType::Paragraph) {
        text = text.replace('\n', ' ');
    } else if (lastBlock.type == BlockType::HtmlBlock) {
        // HTML block can't be incrementally updated — fall back to full parse
        return false;
    }
    // 注意：parseSync 返回 QList<Block>，我们需要的是 inline spans
    // 临时解析整个文本获取最后一个 paragraph 的 spans
    QList<Block> tempBlocks = m_parser->parseSync(text);
    if (!tempBlocks.isEmpty()) {
        lastBlock.spans = tempBlocks.last().spans;
    }

    // 重新估算宽度
    QFont baseFont("Segoe UI", 14);
    QFont codeFont("Consolas", 12);
    lastBlock.estimatedWidth = estimateBlockWidth(lastBlock, baseFont, codeFont);

    m_blocks = m_lastBlocks;
    m_lastSource = m_source;

    // QVariantList 模型不支持 dataChanged，需要 emit blocksChanged
    // 但为了避免 ListView 全量重建，我们在 QML 层做优化
    emit blocksChanged();
    return true;
}

QVariantList MarkdownDocument::blocks() const {
    QVariantList list;
    for (const auto &block : m_blocks) {
        QVariantMap map;
        map["type"] = static_cast<int>(block.type);
        map["spans"] = block.getSpansVariant();
        map["language"] = block.language;
        map["rawText"] = block.rawText;
        map["level"] = block.level;
        map["isTask"] = block.isTask;
        map["taskChecked"] = block.taskChecked;
        map["estimatedWidth"] = block.estimatedWidth;
        map["children"] = block.getChildrenVariant();
        list.append(map);
    }
    return list;
}

bool MarkdownDocument::loading() const { return m_loading; }

QString MarkdownDocument::plainText(int blockIndex) const {
    if (blockIndex < 0 || blockIndex >= m_blocks.size()) return QString();
    QString text;
    for (const auto &span : m_blocks[blockIndex].spans) {
        text += span.text;
    }
    return text;
}

QString MarkdownDocument::blockRawText(int blockIndex) const {
    if (blockIndex < 0 || blockIndex >= m_blocks.size()) return QString();
    return m_blocks[blockIndex].rawText;
}

void MarkdownDocument::copyToClipboard(const QString &text) const {
    QClipboard *clipboard = QGuiApplication::clipboard();
    if (clipboard) {
        clipboard->setText(text);
    }
}

void MarkdownDocument::copyBlock(int blockIndex) const {
    QString text = blockRawText(blockIndex);
    if (!text.isEmpty()) {
        copyToClipboard(text);
    }
}

void MarkdownDocument::copyRange(int startBlock, int endBlock) const {
    if (startBlock < 0) startBlock = 0;
    if (endBlock >= m_blocks.size()) endBlock = m_blocks.size() - 1;
    if (startBlock > endBlock) return;

    QStringList texts;
    for (int i = startBlock; i <= endBlock; ++i) {
        texts.append(m_blocks[i].rawText);
    }
    copyToClipboard(texts.join("\n\n"));
}
