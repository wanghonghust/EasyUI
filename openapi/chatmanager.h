#ifndef CHAT_MANAGER_H
#define CHAT_MANAGER_H

#include <QObject>
#include <QList>
#include <QJsonArray>
#include <qqml.h>
#include "chatsession.h"
#include "openaiconfig.h"

class ChatManager : public QObject
{
    Q_OBJECT
    QML_SINGLETON  // Qt 6 单例宏
    QML_ELEMENT

    Q_PROPERTY(QList<ChatSession*> sessions READ sessions NOTIFY sessionsChanged)
    Q_PROPERTY(int sessionCount READ sessionCount NOTIFY sessionsChanged)
    Q_PROPERTY(ChatSession* currentSession READ currentSession WRITE setCurrentSession NOTIFY currentSessionChanged)
    Q_PROPERTY(OpenAIConfig* defaultConfig READ defaultConfig CONSTANT)

public:
    static ChatManager* create(QQmlEngine *engine, QJSEngine *scriptEngine);

    QList<ChatSession*> sessions() const;
    int sessionCount() const;
    ChatSession* currentSession() const;
    OpenAIConfig* defaultConfig() const;

    // 会话管理
    Q_INVOKABLE ChatSession* createSession(const QString &title = "");
    Q_INVOKABLE void deleteSession(const QString &sessionId);
    Q_INVOKABLE void deleteSession(ChatSession *session);
    Q_INVOKABLE ChatSession* getSession(const QString &sessionId) const;
    Q_INVOKABLE void clearAllSessions();

    // 切换当前会话
    Q_INVOKABLE void switchToSession(const QString &sessionId);
    Q_INVOKABLE void switchToSession(ChatSession *session);

    // 持久化
    Q_INVOKABLE void saveToFile(const QString &path = "");
    Q_INVOKABLE void loadFromFile(const QString &path = "");

    // 从当前会话获取配置创建 OpenAIManager
    Q_INVOKABLE OpenAIConfig* createConfigFromCurrent() const;

    // 获取近期所有会话的消息列表（供用户详情展示）
    Q_INVOKABLE QVariantList recentMessages(int limit = 50) const;

    // 搜索
    Q_INVOKABLE QVariantList searchSessions(const QString &query) const;
    Q_INVOKABLE QVariantList searchSessionsFulltext(const QString &query,
        const QDateTime &fromDate = QDateTime(), const QDateTime &toDate = QDateTime(),
        const QStringList &filterTags = QStringList(), const QString &filterGroup = QString()) const;
    Q_INVOKABLE QList<ChatSession*> pinnedSessions() const;
    Q_INVOKABLE QStringList sessionGroups() const;
    Q_INVOKABLE QList<ChatSession*> sessionsByGroup(const QString &group) const;

    // 导出
    Q_INVOKABLE QString exportSessionToMarkdown(const QString &sessionId) const;
    Q_INVOKABLE QString exportSessionToJson(const QString &sessionId) const;
    Q_INVOKABLE QString exportAllSessionsToJson() const;
    Q_INVOKABLE bool exportSessionsBatch(const QStringList &sessionIds,
        const QString &dirPath, const QString &format = "json") const;
    Q_INVOKABLE bool exportSessionToFile(const QString &sessionId,
        const QString &filePath, const QString &format = "md") const;

    // 时间线
    Q_INVOKABLE QVariantMap getMessageTimeline(const QString &sessionId,
        int page = 0, int pageSize = 50) const;
    Q_INVOKABLE QVariantMap getSessionStats(const QString &sessionId) const;

    // Token 统计
    Q_INVOKABLE QVariantMap getTokenStats(const QString &sessionId = "") const;

signals:
    void sessionsChanged();
    void currentSessionChanged();
    void sessionAdded(ChatSession *session);
    void sessionRemoved(const QString &sessionId);
    void errorOccurred(const QString &error);

private:
    explicit ChatManager(QObject *parent = nullptr);
    ~ChatManager();

    static ChatManager *s_instance;

    QList<ChatSession*> m_sessions;
    ChatSession *m_currentSession;
    OpenAIConfig *m_defaultConfig;  // 新会话的默认配置模板

    QString defaultSavePath() const;
    void setCurrentSession(ChatSession *session);
};

#endif
