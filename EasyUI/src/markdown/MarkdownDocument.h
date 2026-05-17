#ifndef MARKDOWNDOCUMENT_H
#define MARKDOWNDOCUMENT_H

#include <QObject>
#include <QVector>
#include <QVariant>
#include <QUrl>
#include <QTextDocument>
#include <QQmlEngine>
#include <QColor>
#include <QFont>


// 前向声明
class MarkdownStyle;

enum class BlockType {
    Unknown,
    Paragraph,
    Heading1,
    Heading2,
    Heading3,
    Heading4,
    Heading5,
    Heading6,
    CodeBlock,
    BlockQuote,
    ListItem,
    OrderedList,
    UnorderedList,
    HorizontalRule,
    Table,
    Image,
    Link,
    HtmlBlock
};

struct TextSpan {
    Q_GADGET
public:
    QString text;
    bool bold = false;
    bool italic = false;
    bool code = false;
    bool strikethrough = false;
    QColor color;
    QString linkUrl;
    QString imageUrl;  // 图片 URL

    Q_PROPERTY(QString text MEMBER text)
    Q_PROPERTY(bool bold MEMBER bold)
    Q_PROPERTY(bool italic MEMBER italic)
    Q_PROPERTY(bool code MEMBER code)
    Q_PROPERTY(bool strikethrough MEMBER strikethrough)
    Q_PROPERTY(QColor color MEMBER color)
    Q_PROPERTY(QString linkUrl MEMBER linkUrl)
    Q_PROPERTY(QString imageUrl MEMBER imageUrl)
};

struct Block {
    Q_GADGET
public:
    BlockType type = BlockType::Unknown;
    QList<TextSpan> spans;
    QString language;  // For code blocks
    QString rawText;   // Original markdown text
    int level = 0;     // For headings/lists
    bool isTask = false;
    bool taskChecked = false;
    QList<Block> children; // For nested lists
    int estimatedWidth = 0; // 预计算宽度，避免 QML 中测量开销

    Q_PROPERTY(int type READ getType)
    Q_PROPERTY(QVariantList spans READ getSpansVariant)
    Q_PROPERTY(QString language MEMBER language)
    Q_PROPERTY(QString rawText MEMBER rawText)
    Q_PROPERTY(int level MEMBER level)
    Q_PROPERTY(bool isTask MEMBER isTask)
    Q_PROPERTY(bool taskChecked MEMBER taskChecked)
    Q_PROPERTY(QVariantList children READ getChildrenVariant)
    Q_PROPERTY(int estimatedWidth MEMBER estimatedWidth)

    int getType() const { return static_cast<int>(type); }
    QVariantList getSpansVariant() const;
    QVariantList getChildrenVariant() const;
    QString toHtml(const MarkdownStyle *style = nullptr) const; // 预生成 HTML
};

class MarkdownDocument : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QVariantList blocks READ blocks NOTIFY blocksChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit MarkdownDocument(QObject *parent = nullptr);

    QString source() const;
    void setSource(const QString &source);

    QVariantList blocks() const;
    bool loading() const;

    Q_INVOKABLE QString plainText(int blockIndex) const;
    Q_INVOKABLE QString blockRawText(int blockIndex) const;
    Q_INVOKABLE void copyToClipboard(const QString &text) const;
    Q_INVOKABLE void copyBlock(int blockIndex) const;
    Q_INVOKABLE void copyRange(int startBlock, int endBlock) const;

signals:
    void sourceChanged();
    void blocksChanged();
    void loadingChanged();
    void linkActivated(const QString &url);
    void error(const QString &message);

private:
    void parse();
    bool parseIncremental();
    void calculateEstimatedWidths(QList<Block> &blocks);
    int estimateBlockWidth(const Block &block, const QFont &baseFont, const QFont &codeFont);

    QString m_source;
    QList<Block> m_blocks;
    bool m_loading = false;
    class MarkdownParser *m_parser = nullptr;

    // 增量更新相关
    QString m_lastSource;
    QList<Block> m_lastBlocks;
};


#endif