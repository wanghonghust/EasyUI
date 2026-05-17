#ifndef MARKDOWNPARSER_H
#define MARKDOWNPARSER_H

#include <QObject>
#include <QThreadPool>
#include <QRunnable>
#include <QStringList>
#include "MarkdownDocument.h"

class MarkdownParser : public QObject {
    Q_OBJECT
public:
    explicit MarkdownParser(QObject *parent = nullptr);
    ~MarkdownParser();

    void parseAsync(const QString &source);
    QList<Block> parseSync(const QString &source);

signals:
    void parsingFinished(const QList<Block> &blocks);
    void parsingError(const QString &error);

private:
    QList<Block> doParse(const QString &source);
    Block parseParagraph(const QString &line, QStringList &lines, int &index);
    Block parseHeading(const QString &line);
    Block parseCodeBlock(QStringList &lines, int &index, const QString &fence);
    Block parseListItem(const QString &line, QStringList &lines, int &index, int baseIndent);
    Block parseBlockQuote(QStringList &lines, int &index);
    Block parseTable(const QString &line, QStringList &lines, int &index);
    Block parseHtmlBlock(const QString &line, QStringList &lines, int &index);
    QStringList parseTableRow(const QString &line);

    QList<TextSpan> parseInline(const QString &text);
};


#endif