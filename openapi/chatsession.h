#ifndef CHAT_SESSION_H
#define CHAT_SESSION_H

#include <QObject>
#include <QList>
#include <QDateTime>
#include <QJsonArray>
#include <qqml.h>
#include "openaiconfig.h"
#include "chatmessage.h"
#include "openaimanager.h"

class ChatSession : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Use ChatManager to create sessions")

    Q_PROPERTY(QString sessionId READ sessionId CONSTANT)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(OpenAIConfig* config READ config CONSTANT)
    Q_PROPERTY(QList<ChatMessage*> messages READ messages NOTIFY messagesChanged)
    Q_PROPERTY(int messageCount READ messageCount NOTIFY messageCountChanged)
    Q_PROPERTY(QDateTime createTime READ createTime CONSTANT)
    Q_PROPERTY(QDateTime updateTime READ updateTime NOTIFY updateTimeChanged)
    Q_PROPERTY(bool isActive READ isActive WRITE setIsActive NOTIFY isActiveChanged)
    Q_PROPERTY(bool isGenerating READ isGenerating NOTIFY isGeneratingChanged)
    Q_PROPERTY(OpenAIManager* aiManager READ aiManager CONSTANT)
    Q_PROPERTY(bool pinned READ isPinned WRITE setPinned NOTIFY pinnedChanged)
    Q_PROPERTY(QString group READ group WRITE setGroup NOTIFY groupChanged)
    Q_PROPERTY(QStringList tags READ tags WRITE setTags NOTIFY tagsChanged)
    Q_PROPERTY(int activeBranchIndex READ activeBranchIndex WRITE setActiveBranchIndex NOTIFY activeBranchIndexChanged)
    Q_PROPERTY(int branchCount READ branchCount NOTIFY branchCountChanged)

public:
    explicit ChatSession(const QString &title = "新对话",
                         OpenAIConfig *config = nullptr,
                         QObject *parent = nullptr);
    ~ChatSession();

    QString sessionId() const;
    QString title() const;
    OpenAIConfig* config() const;
    QList<ChatMessage*> messages() const;
    int messageCount() const;
    QDateTime createTime() const;
    QDateTime updateTime() const;
    bool isActive() const;
    bool isGenerating() const;
    OpenAIManager* aiManager() const;
    bool isPinned() const;
    QString group() const;
    QStringList tags() const;

    void setPinned(bool pinned);
    void setGroup(const QString &group);
    void setTags(const QStringList &tags);
    int activeBranchIndex() const;
    void setActiveBranchIndex(int idx);
    int branchCount() const;

    Q_INVOKABLE int forkAtMessage(int messageIndex);
    Q_INVOKABLE void switchBranch(int branchIndex);
    Q_INVOKABLE void deleteBranch(int branchIndex);

    Q_INVOKABLE ChatMessage* addUserMessage(const QString &content);
    Q_INVOKABLE ChatMessage* addAssistantMessage(const QString &content);
    Q_INVOKABLE ChatMessage* createStreamingMessage();
    Q_INVOKABLE void clearMessages();
    Q_INVOKABLE void deleteMessage(int index);
    Q_INVOKABLE ChatMessage* messageAt(int index) const;
    Q_INVOKABLE ChatMessage* lastMessage() const;

    // 核心方法：发送消息到 AI
    Q_INVOKABLE void sendMessage(const QString &content);
    Q_INVOKABLE void sendMessageWithAttachments(const QString &content, const QVariantList &attachments);
    Q_INVOKABLE void setWebSearchContext(const QString &context);
    Q_INVOKABLE void cancelGeneration();
    Q_INVOKABLE void regenerateLastMessage();

    Q_INVOKABLE void trimHistory(int maxRounds);
    Q_INVOKABLE void trimHistoryToSize(int maxMessages);
    QJsonArray buildApiMessages() const;

    Q_INVOKABLE QVariantMap getContextUsage() const;
    Q_INVOKABLE void compressContextIfNeeded(double threshold = 0.8);

    Q_INVOKABLE void refreshMessages();
    Q_INVOKABLE void updateMessage(int index, const QString &content);

    void loadFromJson(const QJsonObject &obj);
    QJsonObject toJson() const;

public slots:
    void setTitle(const QString &title);
    void setIsActive(bool active);
    void updateTimestamp();

private slots:
    void onStreamChunk(const QString &chunk);
    void onRequestFinished(bool success);
    void onErrorChanged();

signals:
    void titleChanged();
    void messagesChanged();
    void messageCountChanged();
    void updateTimeChanged();
    void isActiveChanged();
    void isGeneratingChanged();
    void messageAdded(ChatMessage *message);
    void messageRemoved(int index);
    void messageUpdated(int index);
    void messagesCleared();
    void generationStarted();
    void generationFinished(bool success, const QString &error);
    void pinnedChanged();
    void groupChanged();
    void tagsChanged();
    void activeBranchIndexChanged();
    void branchCountChanged();

private:
    QString m_sessionId;
    QString m_title;
    OpenAIConfig *m_config;
    QList<ChatMessage*> m_messages;
    QDateTime m_createTime;
    QDateTime m_updateTime;
    bool m_isActive;
    bool m_isGenerating;

    bool m_pinned = false;
    QString m_group;
    QStringList m_tags;
    OpenAIManager *m_aiManager;  // 每个会话独立的 AI 管理器（非单例）
    ChatMessage *m_currentStreamingMessage;
    QString m_webSearchContext;
    int m_activeBranchIndex = 0;
    int m_branchCount = 1;

    QString generateId() const;
    void setupAIManager();
    void syncHistoryToAI();
    void cleanupGeneration();
};

#endif
