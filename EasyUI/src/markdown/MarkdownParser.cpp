#include "MarkdownParser.h"
#include <QRegularExpression>



MarkdownParser::MarkdownParser(QObject *parent) : QObject(parent) {
}

MarkdownParser::~MarkdownParser() {
}

void MarkdownParser::parseAsync(const QString &source) {
    auto blocks = doParse(source);
    emit parsingFinished(blocks);
}

QList<Block> MarkdownParser::parseSync(const QString &source) {
    return doParse(source);
}

QList<Block> MarkdownParser::doParse(const QString &source) {
    QList<Block> blocks;
    if (source.isEmpty()) return blocks;

    QStringList lines = source.split('\n');
    int i = 0;

    while (i < lines.size()) {
        QString line = lines[i];
        QString trimmed = line.trimmed();

        if (trimmed.isEmpty()) {
            ++i;
            continue;
        }

        Block block;

        // 检测 HTML 块：以 < 开头后跟字母
        QRegularExpression htmlTagRe("^<([a-zA-Z][a-zA-Z0-9]*)");
        if (htmlTagRe.match(trimmed).hasMatch()) {
            block = parseHtmlBlock(line, lines, i);
        }
        // 检测单独的图片行：![alt](url)
        else if (QRegularExpression imageLineRe("^!\\[.*\\]\\(.*\\)$"); imageLineRe.match(trimmed).hasMatch()) {
            block.type = BlockType::Image;
            block.rawText = line;
            block.spans = parseInline(trimmed);
            ++i;
        }
        else if (trimmed.startsWith("```")) {
            block = parseCodeBlock(lines, i, trimmed);
        }
        else if (trimmed.startsWith('#')) {
            block = parseHeading(line);
            ++i;
        }
        else if (trimmed.startsWith('>')) {
            block = parseBlockQuote(lines, i);
        }
        // 检查分割线：三个或更多的 -、*、_（可以有空格分隔）
        else if (QRegularExpression("^([-*_] *){3,}$").match(trimmed).hasMatch()) {
            block.type = BlockType::HorizontalRule;
            block.rawText = line;
            ++i;
        }
        else if (trimmed.startsWith("- ") || trimmed.startsWith("* ") ||
                 trimmed.startsWith("+ ") ||
                 QRegularExpression("^\\d+\\.").match(trimmed).hasMatch()) {
            block = parseListItem(line, lines, i, 0);
        }
        else if (trimmed.contains('|') && i + 1 < lines.size()) {
            QString nextLine = lines[i + 1].trimmed();
            bool isSeparator = nextLine.contains('|') &&
                              nextLine.count('-') >= 2 &&
                              !nextLine.contains(QRegularExpression("[a-zA-Z0-9]"));
            if (isSeparator) {
                block = parseTable(line, lines, i);
            } else {
                block = parseParagraph(line, lines, i);
            }
        }
        else if (trimmed.contains('|')) {
            block = parseParagraph(line, lines, i);
        }
        else {
            block = parseParagraph(line, lines, i);
        }

        if (block.type != BlockType::Unknown) {
            blocks.append(block);
        }
    }

    return blocks;
}

Block MarkdownParser::parseHeading(const QString &line) {
    Block block;
    block.type = BlockType::Unknown;
    block.rawText = line;

    QRegularExpression re("^(#{1,6})\\s+(.+)$");
    QRegularExpressionMatch match = re.match(line.trimmed());

    if (match.hasMatch()) {
        int level = match.captured(1).length();
        QString text = match.captured(2);

        block.type = static_cast<BlockType>(static_cast<int>(BlockType::Heading1) + level - 1);
        block.level = level;
        block.spans = parseInline(text);
    }

    return block;
}

Block MarkdownParser::parseParagraph(const QString &line, QStringList &lines, int &index) {
    Block block;
    block.type = BlockType::Paragraph;
    block.rawText = line;

    QStringList content;
    content.append(line);
    ++index;

    while (index < lines.size()) {
        QString nextLine = lines[index];
        QString nextTrimmed = nextLine.trimmed();
        if (nextTrimmed.isEmpty()) break;
        if (nextTrimmed.startsWith('#')) break;
        if (nextTrimmed.startsWith("```")) break;
        if (nextTrimmed.startsWith(">")) break;
        if (nextTrimmed.startsWith("- ") || nextTrimmed.startsWith("* ") || nextTrimmed.startsWith("+ ")) break;
        if (QRegularExpression("^\\d+\\.").match(nextTrimmed).hasMatch()) break;

        content.append(nextLine);
        block.rawText += "\n" + nextLine;
        ++index;
    }

    QString text = content.join(' ');
    block.spans = parseInline(text);

    return block;
}

Block MarkdownParser::parseCodeBlock(QStringList &lines, int &index, const QString &fence) {
    Block block;
    block.type = BlockType::CodeBlock;
    block.rawText = fence + "\n";

    QString lang = fence.mid(3).trimmed();
    block.language = lang;

    ++index;
    QStringList code;

    while (index < lines.size()) {
        QString line = lines[index];
        if (line.trimmed() == "```") {
            block.rawText += line;
            ++index;
            break;
        }
        code.append(line);
        block.rawText += line + "\n";
        ++index;
    }

    TextSpan span;
    span.text = code.join('\n');
    span.code = true;
    block.spans.append(span);

    return block;
}

Block MarkdownParser::parseListItem(const QString &line, QStringList &lines, int &index, int baseIndent) {
    Block block;
    block.type = BlockType::ListItem;
    block.rawText = line;

    QRegularExpression reUnordered("^([\\s]*)([-*+])\\s+(.*)$");
    QRegularExpression reOrdered("^([\\s]*)(\\d+)\\.\\s+(.*)$");

    QRegularExpressionMatch match = reUnordered.match(line);
    bool isOrdered = false;

    if (!match.hasMatch()) {
        match = reOrdered.match(line);
        isOrdered = true;
    }

    if (match.hasMatch()) {
        int indent = match.captured(1).length();
        QString content = match.captured(3);

        block.type = isOrdered ? BlockType::OrderedList : BlockType::UnorderedList;
        block.level = indent / 2 + 1;

        if (content.startsWith("[ ] ") || content.startsWith("[x] ") || content.startsWith("[X] ")) {
            block.isTask = true;
            block.taskChecked = (content.length() > 1 && (content[1] == 'x' || content[1] == 'X'));
            content = content.mid(4);
        }

        block.spans = parseInline(content);
        ++index;

        int maxIterations = 100;
        int iterations = 0;
        while (index < lines.size() && iterations < maxIterations) {
            iterations++;
            QString nextLine = lines[index];
            QString nextTrimmed = nextLine.trimmed();

            if (nextTrimmed.isEmpty()) {
                ++index;
                continue;
            }

            int nextIndent = nextLine.length() - nextLine.trimmed().length();

            if ((nextTrimmed.startsWith("- ") || nextTrimmed.startsWith("* ") ||
                 nextTrimmed.startsWith("+ ") ||
                 QRegularExpression("^\\d+\\.").match(nextTrimmed).hasMatch())) {
                if (nextIndent > indent) {
                    Block child = parseListItem(nextLine, lines, index, indent);
                    block.children.append(child);
                } else {
                    break;
                }
            } else {
                break;
            }
        }
    } else {
        ++index;
    }

    return block;
}

Block MarkdownParser::parseBlockQuote(QStringList &lines, int &index) {
    Block block;
    block.type = BlockType::BlockQuote;
    block.rawText = lines[index];

    QStringList content;
    QString line = lines[index];
    int pos = line.indexOf('>');
    if (pos >= 0) {
        content.append(line.mid(pos + 1).trimmed());
    }
    ++index;

    while (index < lines.size()) {
        QString nextLine = lines[index];
        if (nextLine.trimmed().startsWith('>')) {
            int p = nextLine.indexOf('>');
            if (p >= 0) {
                content.append(nextLine.mid(p + 1).trimmed());
            }
            block.rawText += "\n" + nextLine;
            ++index;
        } else if (nextLine.trimmed().isEmpty()) {
            ++index;
        } else {
            break;
        }
    }

    block.spans = parseInline(content.join(' '));
    return block;
}

Block MarkdownParser::parseTable(const QString &line, QStringList &lines, int &index) {
    Block block;
    block.type = BlockType::Table;
    block.rawText = line;
    block.level = 0;

    QStringList tableLines;
    tableLines.append(line);

    if (index + 1 < lines.size()) {
        QString separatorLine = lines[index + 1];
        tableLines.append(separatorLine);
        block.rawText += "\n" + separatorLine;
        index += 2;
    } else {
        index += 1;
    }

    while (index < lines.size()) {
        QString nextLine = lines[index];
        QString nextTrimmed = nextLine.trimmed();
        if (nextTrimmed.isEmpty()) break;
        if (!nextTrimmed.contains('|')) break;
        if (nextTrimmed.startsWith('#') || nextTrimmed.startsWith('-') ||
            nextTrimmed.startsWith('*') || nextTrimmed.startsWith('>') ||
            nextTrimmed.startsWith("```")) break;

        tableLines.append(nextLine);
        block.rawText += "\n" + nextLine;
        ++index;
    }

    if (tableLines.size() >= 2) {
        QStringList headers = parseTableRow(tableLines[0]);
        block.level = headers.size();

        TextSpan headerSpan;
        headerSpan.text = headers.join("|");
        headerSpan.bold = true;
        block.spans.append(headerSpan);

        for (int i = 2; i < tableLines.size(); ++i) {
            QStringList cells = parseTableRow(tableLines[i]);
            TextSpan span;
            span.text = cells.join("|");
            block.spans.append(span);
        }
    }

    return block;
}

Block MarkdownParser::parseHtmlBlock(const QString &line, QStringList &lines, int &index) {
    QString trimmed = line.trimmed();
    QRegularExpression tagRe("^<([a-zA-Z][a-zA-Z0-9]*)");
    QRegularExpressionMatch tagMatch = tagRe.match(trimmed);
    if (!tagMatch.hasMatch()) {
        Block block;
        block.type = BlockType::HtmlBlock;
        block.rawText = line;
        ++index;
        return block;
    }

    QString tagName = tagMatch.captured(1).toLower();

    // Self-closing: <img ... />, <br />
    if (trimmed.contains("/>")) {
        Block block;
        block.type = BlockType::HtmlBlock;
        block.rawText = line;
        ++index;
        return block;
    }

    // Void elements — no closing tag needed
    static const QStringList voidElements = {
        "br", "hr", "img", "input", "meta", "link",
        "area", "base", "col", "embed", "source", "track", "wbr"
    };
    if (voidElements.contains(tagName)) {
        Block block;
        block.type = BlockType::HtmlBlock;
        block.rawText = line;
        ++index;
        return block;
    }

    // Collect all lines for this HTML block
    QString fullText = line;
    QRegularExpression closeRe(QString("</%1\\s*>").arg(tagName));

    if (closeRe.match(trimmed).hasMatch()) {
        // Same-line closing tag
        Block block;
        block.type = BlockType::HtmlBlock;
        block.rawText = line;
        ++index;
        // Try to parse as table
        if (tagName == "table") {
            Block tableBlock = parseHtmlTable(fullText);
            if (tableBlock.type == BlockType::Table)
                return tableBlock;
        }
        return block;
    }

    // Multi-line: collect until closing tag found
    int startIdx = index;
    ++index;
    while (index < lines.size()) {
        QString nextLine = lines[index];
        fullText += "\n" + nextLine;
        ++index;
        if (closeRe.match(nextLine.trimmed()).hasMatch())
            break;
    }

    Block block;
    block.type = BlockType::HtmlBlock;
    block.rawText = fullText;

    // Try to parse <table> as structured table
    if (tagName == "table") {
        Block tableBlock = parseHtmlTable(fullText);
        if (tableBlock.type == BlockType::Table)
            return tableBlock;
    }

    return block;
}

Block MarkdownParser::parseHtmlTable(const QString &html) {
    Block block;
    block.type = BlockType::Unknown;

    // Extract all rows from <tr>...</tr>
    QRegularExpression trRe("<tr[^>]*>([\\s\\S]*?)</tr>");
    QRegularExpression tdThRe("<(?:td|th)[^>]*>([\\s\\S]*?)</(?:td|th)>");

    QRegularExpressionMatchIterator trIt = trRe.globalMatch(html);
    QStringList headers;
    QList<QStringList> dataRows;
    bool isFirstRow = true;
    int colCount = 0;

    while (trIt.hasNext()) {
        QRegularExpressionMatch trMatch = trIt.next();
        QString rowContent = trMatch.captured(1);

        QStringList cells;
        QRegularExpressionMatchIterator cellIt = tdThRe.globalMatch(rowContent);
while (cellIt.hasNext()) {
            QRegularExpressionMatch cellMatch = cellIt.next();
            QString cellContent = cellMatch.captured(1).trimmed();
            // Convert <img> tags to markdown image syntax ![alt](url)
            QRegularExpression imgRe("(?i)<img\\s[^>]*>");
            QRegularExpression srcRe("src\\s*=\\s*[\"']([^\"']*)[\"']", QRegularExpression::CaseInsensitiveOption);
            QRegularExpression altRe("alt\\s*=\\s*[\"']([^\"']*)[\"']", QRegularExpression::CaseInsensitiveOption);
            QString result;
            int lastEnd = 0;
            QRegularExpressionMatchIterator imgIt = imgRe.globalMatch(cellContent);
            while (imgIt.hasNext()) {
                QRegularExpressionMatch imgMatch = imgIt.next();
                result += cellContent.mid(lastEnd, imgMatch.capturedStart() - lastEnd);
                QString tag = imgMatch.captured(0);
                auto srcMatch = srcRe.match(tag);
                auto altMatch = altRe.match(tag);
                QString src = srcMatch.hasMatch() ? srcMatch.captured(1) : "";
                QString alt = altMatch.hasMatch() ? altMatch.captured(1) : "";
                if (!src.isEmpty()) {
                    result += "![" + alt + "](" + src + ")";
                }
                lastEnd = imgMatch.capturedEnd();
            }
            result += cellContent.mid(lastEnd);
            cellContent = result;
            // Strip remaining HTML tags, keep text content
            cellContent.remove(QRegularExpression("<[^>]*>"));
            // Decode common HTML entities
            cellContent.replace("&amp;", "&");
            cellContent.replace("&lt;", "<");
            cellContent.replace("&gt;", ">");
            cellContent.replace("&quot;", "\"");
            cellContent.replace("&#39;", "'");
            cellContent.replace("&nbsp;", " ");
            cells.append(cellContent);
        }

        if (cells.isEmpty())
            continue;

        // Detect header row: check if cells are inside <th>
        QRegularExpression thRe("<th[^>]*>");
        QString rowHtml = trMatch.captured(0);
        bool isHeaderRow = thRe.match(rowHtml).hasMatch();

        if (isFirstRow) {
            headers = cells;
            colCount = cells.size();
            isFirstRow = false;
        } else {
            dataRows.append(cells);
        }
    }

    if (headers.isEmpty())
        return block;

    block.type = BlockType::Table;
    block.level = colCount;

    // Build spans in the same format as GFM tables
    // spans[0] = header row joined by "|", bold
    TextSpan headerSpan;
    headerSpan.text = headers.join("|");
    headerSpan.bold = true;
    block.spans.append(headerSpan);

    // spans[1..N] = data rows joined by "|"
    for (const QStringList &row : dataRows) {
        TextSpan span;
        // Pad row to colCount
        QStringList padded;
        for (int i = 0; i < colCount; ++i) {
            padded.append(i < row.size() ? row[i] : "");
        }
        span.text = padded.join("|");
        block.spans.append(span);
    }

    block.rawText = html;
    return block;
}

QStringList MarkdownParser::parseTableRow(const QString &line) {
    QString trimmed = line.trimmed();

    if (trimmed.startsWith('|')) trimmed = trimmed.mid(1);
    if (trimmed.endsWith('|')) trimmed.chop(1);

    QStringList cells = trimmed.split('|');
    for (int i = 0; i < cells.size(); ++i) {
        cells[i] = cells[i].trimmed();
    }

    return cells;
}

QList<TextSpan> MarkdownParser::parseInline(const QString &text) {
    QList<TextSpan> spans;

    if (text.isEmpty()) {
        return spans;
    }

    QString remaining = text;
    int maxIterations = 1000;
    int iterations = 0;

    while (!remaining.isEmpty() && iterations < maxIterations) {
        iterations++;

        int codePos = remaining.indexOf('`');
        int boldPos = remaining.indexOf("**");
        int italicPos = remaining.indexOf('*');
        int imagePos = remaining.indexOf("![");  // 图片：![alt](url)
        int linkPos = remaining.indexOf('[');

        int firstPos = -1;
        QString markerType;

        if (codePos >= 0 && (firstPos < 0 || codePos < firstPos)) { firstPos = codePos; markerType = "code"; }
        if (boldPos >= 0 && (firstPos < 0 || boldPos < firstPos)) { firstPos = boldPos; markerType = "bold"; }
        if (italicPos >= 0 && italicPos != boldPos && (firstPos < 0 || italicPos < firstPos)) { firstPos = italicPos; markerType = "italic"; }
        if (imagePos >= 0 && (firstPos < 0 || imagePos < firstPos)) { firstPos = imagePos; markerType = "image"; }
        if (linkPos >= 0 && (firstPos < 0 || linkPos < firstPos)) { firstPos = linkPos; markerType = "link"; }

        if (firstPos < 0) {
            TextSpan span;
            span.text = remaining;
            spans.append(span);
            break;
        }

        if (firstPos > 0) {
            TextSpan span;
            span.text = remaining.left(firstPos);
            spans.append(span);
        }

        if (markerType == "code") {
            int endPos = remaining.indexOf('`', firstPos + 1);
            if (endPos > firstPos + 1) {
                TextSpan span;
                span.text = remaining.mid(firstPos + 1, endPos - firstPos - 1);
                span.code = true;
                spans.append(span);
                remaining = remaining.mid(endPos + 1);
            } else {
                TextSpan span;
                span.text = remaining.mid(firstPos);
                spans.append(span);
                break;
            }
        } else if (markerType == "bold") {
            int endPos = remaining.indexOf("**", firstPos + 2);
            if (endPos > firstPos + 2) {
                TextSpan span;
                span.text = remaining.mid(firstPos + 2, endPos - firstPos - 2);
                span.bold = true;
                spans.append(span);
                remaining = remaining.mid(endPos + 2);
            } else {
                TextSpan span;
                span.text = remaining.mid(firstPos);
                spans.append(span);
                break;
            }
        } else if (markerType == "italic") {
            int endPos = remaining.indexOf('*', firstPos + 1);
            if (endPos > firstPos + 1 && endPos != remaining.indexOf("**")) {
                TextSpan span;
                span.text = remaining.mid(firstPos + 1, endPos - firstPos - 1);
                span.italic = true;
                spans.append(span);
                remaining = remaining.mid(endPos + 1);
            } else {
                TextSpan span;
                span.text = remaining.mid(firstPos);
                spans.append(span);
                break;
            }
        } else if (markerType == "image") {
            // 图片：![alt](url)
            int textEnd = remaining.indexOf(']', firstPos + 2);  // 从 ! 后面开始
            int urlStart = (textEnd > firstPos + 1) ? remaining.indexOf('(', textEnd) : -1;
            int urlEnd = (urlStart > textEnd) ? remaining.indexOf(')', urlStart) : -1;

            if (textEnd > firstPos + 1 && urlStart == textEnd + 1 && urlEnd > urlStart) {
                TextSpan span;
                span.text = remaining.mid(firstPos + 2, textEnd - firstPos - 2);  // 去掉 ![
                span.imageUrl = remaining.mid(urlStart + 1, urlEnd - urlStart - 1);
                spans.append(span);
                remaining = remaining.mid(urlEnd + 1);
            } else {
                TextSpan span;
                span.text = remaining.mid(firstPos);
                spans.append(span);
                break;
            }
        } else if (markerType == "link") {
            int textEnd = remaining.indexOf(']', firstPos + 1);
            int urlStart = (textEnd > firstPos) ? remaining.indexOf('(', textEnd) : -1;
            int urlEnd = (urlStart > textEnd) ? remaining.indexOf(')', urlStart) : -1;

            if (textEnd > firstPos && urlStart == textEnd + 1 && urlEnd > urlStart) {
                TextSpan span;
                span.text = remaining.mid(firstPos + 1, textEnd - firstPos - 1);
                span.linkUrl = remaining.mid(urlStart + 1, urlEnd - urlStart - 1);
                spans.append(span);
                remaining = remaining.mid(urlEnd + 1);
            } else {
                TextSpan span;
                span.text = remaining.mid(firstPos);
                spans.append(span);
                break;
            }
        }
    }

    if (spans.isEmpty() && !text.isEmpty()) {
        TextSpan span;
        span.text = text;
        spans.append(span);
    }

    return spans;
}
