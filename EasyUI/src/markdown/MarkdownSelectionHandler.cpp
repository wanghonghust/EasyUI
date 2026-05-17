#include "MarkdownSelectionHandler.h"
#include "MarkdownDocument.h"
#include <QClipboard>
#include <QGuiApplication>

MarkdownSelectionHandler::MarkdownSelectionHandler(QObject *parent)
    : QObject(parent)
{
}

bool MarkdownSelectionHandler::hasSelection() const { return m_hasSelection; }
QString MarkdownSelectionHandler::selectedText() const { return m_selectedText; }
int MarkdownSelectionHandler::selStartBlock() const { return m_selStartBlock; }
int MarkdownSelectionHandler::selStartOffset() const { return m_selStartOffset; }
int MarkdownSelectionHandler::selEndBlock() const { return m_selEndBlock; }
int MarkdownSelectionHandler::selEndOffset() const { return m_selEndOffset; }

void MarkdownSelectionHandler::setDocument(MarkdownDocument *doc)
{
    m_document = doc;
}

void MarkdownSelectionHandler::recomputeRange()
{
    if (m_anchorBlock < 0 || m_cursorBlock < 0) {
        m_selStartBlock = -1;
        m_selStartOffset = 0;
        m_selEndBlock = -1;
        m_selEndOffset = 0;
        return;
    }

    if (m_anchorBlock < m_cursorBlock ||
        (m_anchorBlock == m_cursorBlock && m_anchorOffset <= m_cursorOffset)) {
        m_selStartBlock = m_anchorBlock;
        m_selStartOffset = m_anchorOffset;
        m_selEndBlock = m_cursorBlock;
        m_selEndOffset = m_cursorOffset;
    } else {
        m_selStartBlock = m_cursorBlock;
        m_selStartOffset = m_cursorOffset;
        m_selEndBlock = m_anchorBlock;
        m_selEndOffset = m_anchorOffset;
    }
}

void MarkdownSelectionHandler::beginSelection(int blockIndex, int charOffset)
{
    bool wasSelected = m_hasSelection;
    m_hasSelection = false;
    if (wasSelected)
        emit selectionChanged();

    m_anchorBlock = blockIndex;
    m_anchorOffset = charOffset;
    m_cursorBlock = blockIndex;
    m_cursorOffset = charOffset;
    m_selectedText.clear();
    recomputeRange();
    emit selectionChanged();
}

void MarkdownSelectionHandler::updateSelection(int blockIndex, int charOffset)
{
    if (blockIndex < 0) return;

    int oldStart = m_selStartBlock;
    int oldEnd = m_selEndBlock;
    int oldStartOff = m_selStartOffset;
    int oldEndOff = m_selEndOffset;

    m_cursorBlock = blockIndex;
    m_cursorOffset = charOffset;

    m_hasSelection = (m_anchorBlock != m_cursorBlock || m_anchorOffset != m_cursorOffset);
    recomputeRange();

    bool changed = (oldStart != m_selStartBlock || oldEnd != m_selEndBlock
                    || oldStartOff != m_selStartOffset || oldEndOff != m_selEndOffset);
    if (!changed) return;

    m_selectedText.clear();
    emit selectionChanged();
}

void MarkdownSelectionHandler::endSelection()
{
    if (m_hasSelection && m_document) {
        m_selectedText.clear();
        int blockCount = m_document->blocks().size();

        if (m_selStartBlock == m_selEndBlock) {
            QString text = m_document->plainText(m_selStartBlock);
            int start = m_selStartOffset;
            int end = m_selEndOffset;
            if (start >= 0 && end > start && start < text.length())
                m_selectedText = text.mid(start, end - start);
        } else {
            QStringList texts;
            for (int i = m_selStartBlock; i <= m_selEndBlock && i < blockCount; ++i) {
                QString blockText = m_document->plainText(i);
                if (i == m_selStartBlock) {
                    texts.append(blockText.mid(m_selStartOffset));
                } else if (i == m_selEndBlock) {
                    texts.append(blockText.left(m_selEndOffset));
                } else {
                    texts.append(blockText);
                }
            }
            m_selectedText = texts.join("\n");
        }
    }
    emit selectionChanged();
}

void MarkdownSelectionHandler::clearSelection()
{
    m_hasSelection = false;
    m_selectedText.clear();
    m_anchorBlock = -1;
    m_anchorOffset = 0;
    m_cursorBlock = -1;
    m_cursorOffset = 0;
    m_selStartBlock = -1;
    m_selStartOffset = 0;
    m_selEndBlock = -1;
    m_selEndOffset = 0;
    emit selectionChanged();
}

void MarkdownSelectionHandler::selectAll()
{
    if (!m_document) return;
    int count = m_document->blocks().size();
    if (count == 0) return;
    m_anchorBlock = 0;
    m_anchorOffset = 0;
    m_cursorBlock = count - 1;
    m_cursorOffset = m_document->plainText(count - 1).length();
    m_hasSelection = true;
    m_selectedText.clear();
    recomputeRange();
    emit selectionChanged();
}

void MarkdownSelectionHandler::copySelection()
{
    if (m_selectedText.isEmpty()) return;
    QClipboard *clipboard = QGuiApplication::clipboard();
    if (clipboard)
        clipboard->setText(m_selectedText);
}

QVariantMap MarkdownSelectionHandler::selectionForBlock(int blockIndex) const
{
    QVariantMap map;
    if (!m_hasSelection) return map;
    if (blockIndex < m_selStartBlock || blockIndex > m_selEndBlock) return map;

    if (m_selStartBlock == m_selEndBlock) {
        map["start"] = m_selStartOffset;
        map["end"] = m_selEndOffset;
    } else if (blockIndex == m_selStartBlock) {
        map["start"] = m_selStartOffset;
        map["end"] = -1;
    } else if (blockIndex == m_selEndBlock) {
        map["start"] = 0;
        map["end"] = m_selEndOffset;
    } else {
        map["start"] = 0;
        map["end"] = -1;
    }

    return map;
}

void MarkdownSelectionHandler::collectBlockText(int blockIndex, const QString &text)
{
    Q_UNUSED(blockIndex)
    Q_UNUSED(text)
}