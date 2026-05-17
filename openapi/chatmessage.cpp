#include "chatmessage.h"
#include <QJsonArray>

ChatMessage::ChatMessage(Role role, const QString &content, QObject *parent)
    : QObject(parent)
    , m_role(role)
    , m_content(content)
    , m_streamingContent("")
    , m_timestamp(QDateTime::currentDateTime())
    , m_isStreaming(false)
{
}

void ChatMessage::loadFromJson(const QJsonObject &obj)
{
    QString roleStr = obj["role"].toString();
    if (roleStr == "system") m_role = SystemRole;
    else if (roleStr == "assistant") m_role = AssistantRole;
    else m_role = UserRole;

    m_content = obj["content"].toString();
    m_timestamp = QDateTime::fromString(obj["timestamp"].toString(), Qt::ISODate);
    m_isStreaming = false;
    m_attachments = obj["attachments"].toArray().toVariantList();
    m_parentMessageId = obj["parentMessageId"].toString();
    m_branchIndex = obj["branchIndex"].toInt(0);
}

QJsonObject ChatMessage::toJson() const
{
    QJsonObject obj;
    obj["role"] = (m_role == SystemRole) ? "system" :
                      (m_role == AssistantRole) ? "assistant" : "user";
    obj["content"] = m_content;
    obj["timestamp"] = m_timestamp.toString(Qt::ISODate);
    if (!m_attachments.isEmpty())
        obj["attachments"] = QJsonArray::fromVariantList(m_attachments);
    if (!m_parentMessageId.isEmpty())
        obj["parentMessageId"] = m_parentMessageId;
    if (m_branchIndex != 0)
        obj["branchIndex"] = m_branchIndex;
    return obj;
}

QString ChatMessage::role() const
{
    return (m_role == SystemRole) ? "system" :
               (m_role == AssistantRole) ? "assistant" : "user";
}

QString ChatMessage::content() const { return m_content; }
QString ChatMessage::streamingContent() const { return m_streamingContent; }
QDateTime ChatMessage::timestamp() const { return m_timestamp; }
bool ChatMessage::isStreaming() const { return m_isStreaming; }
QVariantList ChatMessage::attachments() const { return m_attachments; }
QString ChatMessage::parentMessageId() const { return m_parentMessageId; }
int ChatMessage::branchIndex() const { return m_branchIndex; }

void ChatMessage::setParentMessageId(const QString &id) {
    if (m_parentMessageId != id) { m_parentMessageId = id; emit parentMessageIdChanged(); }
}
void ChatMessage::setBranchIndex(int idx) {
    if (m_branchIndex != idx) { m_branchIndex = idx; emit branchIndexChanged(); }
}

void ChatMessage::setAttachments(const QVariantList &attachments)
{
    if (m_attachments != attachments) {
        m_attachments = attachments;
        emit attachmentsChanged();
    }
}

void ChatMessage::setContent(const QString &content)
{
    if (m_content != content) {
        m_content = content;
        emit contentChanged();
    }
}

void ChatMessage::setIsStreaming(bool streaming)
{
    if (m_isStreaming != streaming) {
        m_isStreaming = streaming;
        emit isStreamingChanged();
    }
}

void ChatMessage::appendStreamingContent(const QString &text)
{
    m_streamingContent += text;
    emit streamingContentChanged();
}

void ChatMessage::finalizeStreaming()
{
    if (!m_streamingContent.isEmpty()) {
        m_content = m_streamingContent;
        m_streamingContent.clear();
    }
    m_isStreaming = false;
    emit contentChanged();
    emit streamingContentChanged();
    emit isStreamingChanged();
}