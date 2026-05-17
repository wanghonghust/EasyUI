#include "chatmanager.h"
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QRegularExpression>
#include <QDebug>

ChatManager *ChatManager::s_instance = nullptr;

ChatManager* ChatManager::create(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    if (!s_instance) {
        s_instance = new ChatManager();
    }
    return s_instance;
}

ChatManager::ChatManager(QObject *parent)
    : QObject(parent)
    , m_currentSession(nullptr)
    , m_defaultConfig(new OpenAIConfig(this))
{
    // 设置默认配置
    m_defaultConfig->setModel("qwen-plus");
    m_defaultConfig->setBaseUrl("https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions");
    m_defaultConfig->setSystemMessage("You are a helpful assistant.");
    m_defaultConfig->setMaxHistoryRounds(10);

    // 自动加载
    loadFromFile();
}

ChatManager::~ChatManager()
{
    saveToFile();
    qDeleteAll(m_sessions);
}

QList<ChatSession*> ChatManager::sessions() const { return m_sessions; }
int ChatManager::sessionCount() const { return m_sessions.size(); }
ChatSession* ChatManager::currentSession() const { return m_currentSession; }
OpenAIConfig* ChatManager::defaultConfig() const { return m_defaultConfig; }

ChatSession* ChatManager::createSession(const QString &title)
{
    // 复制默认配置给新会话
    OpenAIConfig *config = m_defaultConfig->clone(this);

    QString sessionTitle = title;
    if (sessionTitle.isEmpty()) {
        sessionTitle = QString("对话 %1").arg(m_sessions.size() + 1);
    }

    auto *session = new ChatSession(sessionTitle, config, this);
    m_sessions.append(session);

    emit sessionAdded(session);
    emit sessionsChanged();

    // 自动切换到新会话
    switchToSession(session);

    return session;
}

void ChatManager::deleteSession(const QString &sessionId)
{
    for (int i = 0; i < m_sessions.size(); ++i) {
        if (m_sessions[i]->sessionId() == sessionId) {
            deleteSession(m_sessions[i]);
            return;
        }
    }
}

void ChatManager::deleteSession(ChatSession *session)
{
    if (!session || !m_sessions.contains(session)) return;

    // 如果删除的是当前会话，先切换
    if (m_currentSession == session) {
        int idx = m_sessions.indexOf(session);
        if (m_sessions.size() > 1) {
            // 切换到前一个或后一个
            ChatSession *next = m_sessions[(idx + 1) % m_sessions.size()];
            if (next == session) next = m_sessions[0];
            switchToSession(next);
        } else {
            setCurrentSession(nullptr);
        }
    }

    QString sid = session->sessionId();
    m_sessions.removeOne(session);
    session->deleteLater();

    emit sessionRemoved(sid);
    emit sessionsChanged();
}

ChatSession* ChatManager::getSession(const QString &sessionId) const
{
    for (auto *s : m_sessions) {
        if (s->sessionId() == sessionId) return s;
    }
    return nullptr;
}

void ChatManager::clearAllSessions()
{
    qDeleteAll(m_sessions);
    m_sessions.clear();
    setCurrentSession(nullptr);
    emit sessionsChanged();
}

void ChatManager::switchToSession(const QString &sessionId)
{
    ChatSession *s = getSession(sessionId);
    if (s) switchToSession(s);
}

void ChatManager::switchToSession(ChatSession *session)
{
    qDebug() << "session" << session->sessionId();
    if (!m_sessions.contains(session)) return;
    setCurrentSession(session);
}

void ChatManager::setCurrentSession(ChatSession *session)
{
    if (m_currentSession) {
        m_currentSession->setIsActive(false);
    }

    m_currentSession = session;

    if (m_currentSession) {
        m_currentSession->setIsActive(true);
    }

    emit currentSessionChanged();
}

OpenAIConfig* ChatManager::createConfigFromCurrent() const
{
    if (!m_currentSession) return m_defaultConfig->clone();
    return m_currentSession->config()->clone();
}

QVariantList ChatManager::recentMessages(int limit) const
{
    QVariantList result;
    struct MsgItem {
        QDateTime time;
        QString sessionTitle;
        const ChatMessage *msg;
    };
    QList<MsgItem> allMsgs;

    for (const auto *session : std::as_const(m_sessions)) {
        for (const auto *msg : session->messages()) {
            MsgItem item;
            item.time = msg->timestamp();
            item.sessionTitle = session->title();
            item.msg = msg;
            allMsgs.append(item);
        }
    }

    // 按时间倒序
    std::sort(allMsgs.begin(), allMsgs.end(), [](const MsgItem &a, const MsgItem &b) {
        return a.time > b.time;
    });

    int count = (limit <= 0) ? allMsgs.size() : qMin(limit, allMsgs.size());
    for (int i = 0; i < count; ++i) {
        const auto &item = allMsgs[i];
        const auto *msg = item.msg;
        QVariantMap map;
        map["time"] = item.time.toString("yyyy-MM-dd hh:mm");
        map["session"] = item.sessionTitle;
        QString roleStr = msg->role();
        map["role"] = (roleStr == "user") ? "用户" : (roleStr == "assistant" ? "AI" : "系统");
        QString content = msg->content();
        map["preview"] = content.left(40) + (content.length() > 40 ? "..." : "");
        map["length"] = content.length();
        result.append(map);
    }

    return result;
}

QString ChatManager::defaultSavePath() const
{
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(path);
    return path + "/chat_sessions.json";
}

void ChatManager::saveToFile(const QString &path)
{
    QString savePath = path.isEmpty() ? defaultSavePath() : path;

    QJsonArray arr;
    for (const auto *s : std::as_const(m_sessions)) {
        arr.append(s->toJson());
    }

    QJsonObject root;
    root["version"] = "1.0";
    root["defaultConfig"] = m_defaultConfig->toJson();
    root["sessions"] = arr;
    if (m_currentSession) {
        root["currentSessionId"] = m_currentSession->sessionId();
    }

    QFile file(savePath);
    if (file.open(QIODevice::WriteOnly)) {
        file.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
        qDebug() << "Saved" << m_sessions.size() << "sessions to" << savePath;
    } else {
        emit errorOccurred("无法保存会话: " + file.errorString());
    }
}

void ChatManager::loadFromFile(const QString &path)
{
    QString loadPath = path.isEmpty() ? defaultSavePath() : path;

    QFile file(loadPath);
    if (!file.exists()) {
        // 文件不存在，创建一个默认会话
        createSession("默认对话");
        return;
    }

    if (!file.open(QIODevice::ReadOnly)) {
        emit errorOccurred("无法加载会话: " + file.errorString());
        return;
    }

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    if (doc.isNull()) {
        emit errorOccurred("会话文件格式错误");
        return;
    }

    QJsonObject root = doc.object();

    // 加载默认配置
    m_defaultConfig->loadFromJson(root["defaultConfig"].toObject());

    // 加载会话
    QJsonArray arr = root["sessions"].toArray();
    QString currentId = root["currentSessionId"].toString();

    for (const auto &val : arr) {
        auto *session = new ChatSession("", nullptr, this);
        session->loadFromJson(val.toObject());
        m_sessions.append(session);
        emit sessionAdded(session);

        if (session->sessionId() == currentId) {
            setCurrentSession(session);
        }
    }

    // 如果没有当前会话，选第一个
    if (!m_currentSession && !m_sessions.isEmpty()) {
        setCurrentSession(m_sessions.first());
    }

    // 如果没有会话，创建一个
    if (m_sessions.isEmpty()) {
        createSession("默认对话");
    }

    emit sessionsChanged();
    qDebug() << "Loaded" << m_sessions.size() << "sessions";
}

// ============= 搜索 =============
QVariantList ChatManager::searchSessions(const QString &query) const
{
    QVariantList results;
    if (query.trimmed().isEmpty()) return results;
    QString q = query.toLower();

    for (const auto *session : std::as_const(m_sessions)) {
        // 检查标题匹配
        int titleScore = 0;
        if (session->title().toLower().contains(q))
            titleScore = 10;
        // 检查标签匹配
        int tagScore = 0;
        for (const auto &tag : session->tags()) {
            if (tag.toLower().contains(q)) { tagScore = 5; break; }
        }
        // 检查组匹配
        int groupScore = 0;
        if (session->group().toLower().contains(q))
            groupScore = 3;

        // 检查消息内容匹配
        int msgScore = 0;
        QString matchPreview;
        for (const auto *msg : session->messages()) {
            QString content = msg->content().toLower();
            int idx = content.indexOf(q);
            if (idx >= 0) {
                msgScore = 2;
                int start = qMax(0, idx - 20);
                int len = qMin(content.length() - start, 80);
                matchPreview = msg->content().mid(start, len);
                if (start > 0) matchPreview = "..." + matchPreview;
                if (start + len < msg->content().length()) matchPreview += "...";
                break;
            }
        }

        int totalScore = titleScore + tagScore + groupScore + msgScore;
        if (totalScore > 0) {
            QVariantMap item;
            item["sessionId"] = session->sessionId();
            item["title"] = session->title();
            item["score"] = totalScore;
            item["matchPreview"] = matchPreview;
            item["messageCount"] = session->messageCount();
            item["pinned"] = session->isPinned();
            item["group"] = session->group();
            results.append(item);
        }
    }

    // 按分数排序
    std::sort(results.begin(), results.end(), [](const QVariant &a, const QVariant &b) {
        return a.toMap()["score"].toInt() > b.toMap()["score"].toInt();
    });

    return results;
}

QList<ChatSession*> ChatManager::pinnedSessions() const
{
    QList<ChatSession*> result;
    for (auto *s : m_sessions) {
        if (s->isPinned()) result.append(s);
    }
    return result;
}

QStringList ChatManager::sessionGroups() const
{
    QStringList groups;
    for (const auto *s : m_sessions) {
        if (!s->group().isEmpty() && !groups.contains(s->group()))
            groups.append(s->group());
    }
    return groups;
}

QList<ChatSession*> ChatManager::sessionsByGroup(const QString &group) const
{
    QList<ChatSession*> result;
    for (auto *s : m_sessions) {
        if (s->group() == group) result.append(s);
    }
    return result;
}

// ============= 导出 =============
QString ChatManager::exportSessionToMarkdown(const QString &sessionId) const
{
    ChatSession *s = getSession(sessionId);
    if (!s) return "";

    QString md;
    md += "# " + s->title() + "\n\n";
    md += "> 创建时间: " + s->createTime().toString("yyyy-MM-dd hh:mm:ss") + "\n";
    md += "> 消息数: " + QString::number(s->messageCount()) + "\n";
    if (!s->group().isEmpty()) md += "> 分组: " + s->group() + "\n";
    if (!s->tags().isEmpty()) md += "> 标签: " + s->tags().join(", ") + "\n";
    md += "\n---\n\n";

    for (const auto *msg : s->messages()) {
        QString role = msg->role();
        if (role == "user") {
            md += "### 👤 用户\n\n" + msg->content() + "\n\n";
        } else if (role == "assistant") {
            md += "### 🤖 AI\n\n" + msg->content() + "\n\n";
        }
    }

    return md;
}

QString ChatManager::exportSessionToJson(const QString &sessionId) const
{
    ChatSession *s = getSession(sessionId);
    if (!s) return "";

    QJsonObject obj = s->toJson();
    QJsonDocument doc(obj);
    return doc.toJson(QJsonDocument::Indented);
}

QString ChatManager::exportAllSessionsToJson() const
{
    QJsonArray arr;
    for (const auto *s : m_sessions) {
        arr.append(s->toJson());
    }
    QJsonObject root;
    root["version"] = "2.0";
    root["exportTime"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    root["sessions"] = arr;

    QJsonDocument doc(root);
    return doc.toJson(QJsonDocument::Indented);
}

// ============= Token 统计 =============
QVariantMap ChatManager::getTokenStats(const QString &sessionId) const
{
    QVariantMap stats;
    int totalMessages = 0;
    int totalUserMessages = 0;
    int totalAssistantMessages = 0;
    qint64 totalChars = 0;
    qint64 estimatedTokens = 0;

    auto countSession = [&](const ChatSession *s) {
        for (const auto *msg : s->messages()) {
            totalMessages++;
            if (msg->role() == "user") totalUserMessages++;
            else if (msg->role() == "assistant") totalAssistantMessages++;
            qint64 chars = msg->content().length();
            totalChars += chars;
            // Rough estimate: ~4 chars per token
            estimatedTokens += chars / 4 + 1;
        }
    };

    if (sessionId.isEmpty()) {
        for (const auto *s : m_sessions) countSession(s);
        stats["sessionCount"] = m_sessions.size();
    } else {
        ChatSession *s = getSession(sessionId);
        if (s) { countSession(s); stats["sessionCount"] = 1; }
    }

    stats["totalMessages"] = totalMessages;
    stats["userMessages"] = totalUserMessages;
    stats["assistantMessages"] = totalAssistantMessages;
    stats["totalChars"] = totalChars;
    stats["estimatedTokens"] = estimatedTokens;
    // Rough cost estimate: $0.002/1K tokens (GPT-4o-mini pricing)
    stats["estimatedCost"] = QString::number(estimatedTokens * 0.002 / 1000.0, 'f', 4);

    return stats;
}

// ============= 增强全文搜索 =============
QVariantList ChatManager::searchSessionsFulltext(const QString &query,
    const QDateTime &fromDate, const QDateTime &toDate,
    const QStringList &filterTags, const QString &filterGroup) const
{
    QVariantList results;
    if (query.trimmed().isEmpty() && !fromDate.isValid() && !toDate.isValid()
        && filterTags.isEmpty() && filterGroup.isEmpty()) {
        // No filters: return all sessions with basic info
        for (const auto *s : m_sessions) {
            QVariantMap item;
            item["sessionId"] = s->sessionId();
            item["title"] = s->title();
            item["score"] = 0;
            item["messageCount"] = s->messageCount();
            item["pinned"] = s->isPinned();
            item["group"] = s->group();
            item["tags"] = s->tags();
            item["updateTime"] = s->updateTime().toString(Qt::ISODate);
            results.append(item);
        }
        return results;
    }

    QString q = query.toLower();
    QStringList queryWords = q.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);

    for (const auto *s : m_sessions) {
        // Date range filter
        if (fromDate.isValid() && s->updateTime() < fromDate) continue;
        if (toDate.isValid() && s->updateTime() > toDate) continue;

        // Group filter
        if (!filterGroup.isEmpty() && s->group() != filterGroup) continue;

        // Tag filter (OR: any matching tag)
        if (!filterTags.isEmpty()) {
            bool tagMatch = false;
            for (const auto &t : filterTags) {
                if (s->tags().contains(t, Qt::CaseInsensitive)) { tagMatch = true; break; }
            }
            if (!tagMatch) continue;
        }

        // If no query, include all that pass filters
        if (q.isEmpty()) {
            QVariantMap item;
            item["sessionId"] = s->sessionId();
            item["title"] = s->title();
            item["score"] = 0;
            item["messageCount"] = s->messageCount();
            item["pinned"] = s->isPinned();
            item["group"] = s->group();
            item["tags"] = s->tags();
            item["updateTime"] = s->updateTime().toString(Qt::ISODate);
            results.append(item);
            continue;
        }

        // Multi-pass scoring
        int score = 0;
        QString matchPreview;

        // Pass 1: exact title match (+20)
        if (s->title().toLower() == q)
            score += 20;

        // Pass 2: title contains query (+10)
        if (s->title().toLower().contains(q))
            score += 10;

        // Pass 3: tag match (+5)
        for (const auto &tag : s->tags()) {
            if (tag.toLower().contains(q)) { score += 5; break; }
        }

        // Pass 4: group match (+3)
        if (s->group().toLower().contains(q))
            score += 3;

        // Pass 5: message content — all words match within window (+15), any word (+2)
        int bestMsgScore = 0;
        for (const auto *msg : s->messages()) {
            QString content = msg->content().toLower();

            // All words present check
            bool allWords = true;
            for (const auto &w : queryWords) {
                if (!content.contains(w)) { allWords = false; break; }
            }
            if (allWords && !queryWords.isEmpty())
                bestMsgScore = qMax(bestMsgScore, 15);

            // Any word match
            for (const auto &w : queryWords) {
                int idx = content.indexOf(w);
                if (idx >= 0) {
                    bestMsgScore = qMax(bestMsgScore, 2);
                    // Extract preview
                    int start = qMax(0, idx - 40);
                    int len = qMin(content.length() - start, 100);
                    matchPreview = msg->content().mid(start, len);
                    if (start > 0) matchPreview = "..." + matchPreview;
                    if (start + len < msg->content().length()) matchPreview += "...";
                    break;
                }
            }
        }
        score += bestMsgScore;

        if (score > 0) {
            QVariantMap item;
            item["sessionId"] = s->sessionId();
            item["title"] = s->title();
            item["score"] = score;
            item["matchPreview"] = matchPreview;
            item["messageCount"] = s->messageCount();
            item["pinned"] = s->isPinned();
            item["group"] = s->group();
            item["tags"] = s->tags();
            item["updateTime"] = s->updateTime().toString(Qt::ISODate);
            results.append(item);
        }
    }

    std::sort(results.begin(), results.end(), [](const QVariant &a, const QVariant &b) {
        return a.toMap()["score"].toInt() > b.toMap()["score"].toInt();
    });

    return results;
}

// ============= 批量导出 =============
bool ChatManager::exportSessionToFile(const QString &sessionId,
    const QString &filePath, const QString &format) const
{
    ChatSession *s = getSession(sessionId);
    if (!s) return false;

    QString content;
    if (format == "md") {
        content = exportSessionToMarkdown(sessionId);
    } else if (format == "json") {
        content = exportSessionToJson(sessionId);
    } else if (format == "html") {
        // Simple HTML conversion
        QString md = exportSessionToMarkdown(sessionId);
        content = "<html><head><meta charset=\"utf-8\"><style>"
                  "body{font-family:sans-serif;max-width:800px;margin:0 auto;padding:20px;line-height:1.7}"
                  "h1{border-bottom:1px solid #ddd} h3{margin:16px 0 8px}"
                  "pre{background:#f5f5f5;padding:12px;border-radius:6px;white-space:pre-wrap}"
                  "</style></head><body>";
        // Basic markdown to HTML (paragraphs, code blocks)
        for (const auto &line : md.split('\n')) {
            if (line.startsWith("# "))
                content += "<h1>" + line.mid(2).toHtmlEscaped() + "</h1>\n";
            else if (line.startsWith("## "))
                content += "<h2>" + line.mid(3).toHtmlEscaped() + "</h2>\n";
            else if (line.startsWith("### "))
                content += "<h3>" + line.mid(4).toHtmlEscaped() + "</h3>\n";
            else if (line.startsWith("> "))
                content += "<blockquote>" + line.mid(2).toHtmlEscaped() + "</blockquote>\n";
            else if (line.startsWith("---"))
                content += "<hr>\n";
            else if (!line.isEmpty())
                content += "<p>" + line.toHtmlEscaped().replace("\n", "<br>") + "</p>\n";
            else
                content += "<br>\n";
        }
        content += "</body></html>";
    } else {
        return false;
    }

    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) return false;
    file.write(content.toUtf8());
    file.close();
    return true;
}

bool ChatManager::exportSessionsBatch(const QStringList &sessionIds,
    const QString &dirPath, const QString &format) const
{
    QDir dir(dirPath);
    if (!dir.exists()) dir.mkpath(".");

    int count = 0;
    for (const auto &id : sessionIds) {
        ChatSession *s = getSession(id);
        if (!s) continue;

        QString safeName = s->title();
        safeName.replace(QRegularExpression("[\\\\/:*?\"<>|]"), "_");
        QString ext = (format == "md") ? ".md" : ((format == "html") ? ".html" : ".json");
        QString path = dir.filePath(safeName + ext);

        // Avoid overwrite
        int dedup = 1;
        while (QFile::exists(path)) {
            path = dir.filePath(safeName + "_" + QString::number(dedup++) + ext);
        }

        if (exportSessionToFile(id, path, format)) count++;
    }
    return count > 0;
}

// ============= 时间线 =============
QVariantMap ChatManager::getMessageTimeline(const QString &sessionId,
    int page, int pageSize) const
{
    QVariantMap result;
    ChatSession *s = getSession(sessionId);
    if (!s) {
        result["error"] = "Session not found";
        return result;
    }

    QVariantList timeline;
    QDateTime lastDate;
    QVariantMap dateGroup;

    int total = s->messageCount();
    int startIdx = page * pageSize;
    int endIdx = qMin(startIdx + pageSize, total);

    for (int i = startIdx; i < endIdx; i++) {
        ChatMessage *msg = s->messageAt(i);
        if (!msg) continue;

        QDate msgDate = msg->timestamp().date();
        QVariantMap item;
        item["index"] = i;
        item["role"] = msg->role();
        item["content"] = msg->content().left(200); // truncated preview
        item["timestamp"] = msg->timestamp().toString(Qt::ISODate);
        item["dateLabel"] = msg->timestamp().toString("yyyy-MM-dd");
        timeline.append(item);
    }

    result["timeline"] = timeline;
    result["total"] = total;
    result["page"] = page;
    result["pageSize"] = pageSize;
    result["hasMore"] = endIdx < total;
    return result;
}

QVariantMap ChatManager::getSessionStats(const QString &sessionId) const
{
    QVariantMap stats;
    ChatSession *s = getSession(sessionId);
    if (!s) return stats;

    stats["messageCount"] = s->messageCount();
    stats["createTime"] = s->createTime().toString(Qt::ISODate);
    stats["updateTime"] = s->updateTime().toString(Qt::ISODate);
    stats["pinned"] = s->isPinned();
    stats["group"] = s->group();
    stats["tags"] = s->tags();

    QDate today = QDate::currentDate();
    int todayMsgs = 0, weekMsgs = 0, monthMsgs = 0;
    for (const auto *msg : s->messages()) {
        QDate d = msg->timestamp().date();
        if (d == today) todayMsgs++;
        if (d >= today.addDays(-7)) weekMsgs++;
        if (d >= today.addDays(-30)) monthMsgs++;
    }
    stats["todayMessages"] = todayMsgs;
    stats["weekMessages"] = weekMsgs;
    stats["monthMessages"] = monthMsgs;

    return stats;
}
