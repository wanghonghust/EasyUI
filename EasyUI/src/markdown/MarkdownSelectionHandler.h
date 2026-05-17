#ifndef MARKDOWNSELECTIONHANDLER_H
#define MARKDOWNSELECTIONHANDLER_H

#include <QObject>
#include <QQmlEngine>

class MarkdownDocument;

class MarkdownSelectionHandler : public QObject {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(bool hasSelection READ hasSelection NOTIFY selectionChanged)
    Q_PROPERTY(QString selectedText READ selectedText NOTIFY selectionChanged)
    Q_PROPERTY(int selStartBlock READ selStartBlock NOTIFY selectionChanged)
    Q_PROPERTY(int selStartOffset READ selStartOffset NOTIFY selectionChanged)
    Q_PROPERTY(int selEndBlock READ selEndBlock NOTIFY selectionChanged)
    Q_PROPERTY(int selEndOffset READ selEndOffset NOTIFY selectionChanged)

public:
    explicit MarkdownSelectionHandler(QObject *parent = nullptr);

    bool hasSelection() const;
    QString selectedText() const;
    int selStartBlock() const;
    int selStartOffset() const;
    int selEndBlock() const;
    int selEndOffset() const;

    Q_INVOKABLE void setDocument(MarkdownDocument *doc);

    Q_INVOKABLE void beginSelection(int blockIndex, int charOffset);
    Q_INVOKABLE void updateSelection(int blockIndex, int charOffset);
    Q_INVOKABLE void endSelection();
    Q_INVOKABLE void clearSelection();
    Q_INVOKABLE void selectAll();
    Q_INVOKABLE void copySelection();

    // Returns {start: int, end: int} or empty map if block not in selection
    Q_INVOKABLE QVariantMap selectionForBlock(int blockIndex) const;

    // Called from QML to feed selected text per block (unused, kept for compat)
    Q_INVOKABLE void collectBlockText(int blockIndex, const QString &text);

signals:
    void selectionChanged();

private:
    void recomputeRange();

    bool m_hasSelection = false;
    QString m_selectedText;

    // Anchor: fixed point where mouse was pressed
    int m_anchorBlock = -1;
    int m_anchorOffset = 0;
    // Cursor: current mouse position
    int m_cursorBlock = -1;
    int m_cursorOffset = 0;

    // Computed selection range (always start <= end)
    int m_selStartBlock = -1;
    int m_selStartOffset = 0;
    int m_selEndBlock = -1;
    int m_selEndOffset = 0;

    MarkdownDocument *m_document = nullptr;
};

#endif