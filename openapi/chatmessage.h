#ifndef CHAT_MESSAGE_H
#define CHAT_MESSAGE_H

#include <QObject>
#include <QDateTime>
#include <QJsonObject>
#include <qqml.h>

class ChatMessage : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Use ChatSession to create messages")

    Q_PROPERTY(QString role READ role CONSTANT)
    Q_PROPERTY(QString content READ content WRITE setContent NOTIFY contentChanged)
    Q_PROPERTY(QString streamingContent READ streamingContent NOTIFY streamingContentChanged)
    Q_PROPERTY(QDateTime timestamp READ timestamp CONSTANT)
    Q_PROPERTY(bool isStreaming READ isStreaming WRITE setIsStreaming NOTIFY isStreamingChanged)
    Q_PROPERTY(QVariantList attachments READ attachments WRITE setAttachments NOTIFY attachmentsChanged)
    Q_PROPERTY(QString parentMessageId READ parentMessageId WRITE setParentMessageId NOTIFY parentMessageIdChanged)
    Q_PROPERTY(int branchIndex READ branchIndex WRITE setBranchIndex NOTIFY branchIndexChanged)

public:
    enum Role {
        SystemRole,
        UserRole,
        AssistantRole
    };
    Q_ENUM(Role)

    explicit ChatMessage(Role role, const QString &content, QObject *parent = nullptr);

    void loadFromJson(const QJsonObject &obj);
    QJsonObject toJson() const;

    QString role() const;
    QString content() const;
    QString streamingContent() const;
    QDateTime timestamp() const;
    bool isStreaming() const;
    QVariantList attachments() const;
    QString parentMessageId() const;
    int branchIndex() const;

    void setContent(const QString &content);
    void setIsStreaming(bool streaming);
    void setAttachments(const QVariantList &attachments);
    void setParentMessageId(const QString &id);
    void setBranchIndex(int idx);
    Q_INVOKABLE void appendStreamingContent(const QString &text);
    Q_INVOKABLE void finalizeStreaming();

signals:
    void contentChanged();
    void streamingContentChanged();
    void isStreamingChanged();
    void attachmentsChanged();
    void parentMessageIdChanged();
    void branchIndexChanged();

private:
    Role m_role;
    QString m_content;
    QString m_streamingContent;
    QDateTime m_timestamp;
    bool m_isStreaming;
    QVariantList m_attachments;
    QString m_parentMessageId;
    int m_branchIndex = 0;
};

#endif