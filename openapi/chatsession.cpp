#include "chatsession.h"
#include <QUuid>
#include <QDebug>

ChatSession::ChatSession(const QString &title, OpenAIConfig *config, QObject *parent)
    : QObject(parent)
    , m_sessionId(generateId())
    , m_title(title.isEmpty() ? "新对话" : title)
    , m_config(config ? config : new OpenAIConfig(this))
    , m_createTime(QDateTime::currentDateTime())
    , m_updateTime(QDateTime::currentDateTime())
    , m_isActive(false)
    , m_isGenerating(false)
    , m_aiManager(nullptr)
    , m_currentStreamingMessage(nullptr)
{
    if (!config) {
        m_config->setParent(this);
    }
    setupAIManager();
}

ChatSession::~ChatSession()
{
    qDeleteAll(m_messages);
    // m_aiManager 会随着 parent 自动删除
}

QString ChatSession::generateId() const
{
    return QUuid::createUuid().toString(QUuid::WithoutBraces);
}

void ChatSession::setupAIManager()
{
    // 创建非单例的 OpenAIManager，设置当前会话为 parent
    m_aiManager = new OpenAIManager(this);

    // 从配置同步初始设置
    m_aiManager->setApiKey(m_config->apiKey());
    m_aiManager->setBaseUrl(m_config->baseUrl());
    m_aiManager->setModel(m_config->model());
    m_aiManager->setStreamMode(m_config->streamMode());
    m_aiManager->setMaxHistoryRounds(m_config->maxHistoryRounds());
    m_aiManager->setMaxTokens(m_config->maxTokens());
    m_aiManager->setReasoningEnabled(m_config->reasoningEnabled());
    m_aiManager->setSearchEnabled(m_config->searchEnabled());
    m_aiManager->setVendorCode(m_config->vendorCode());
    m_aiManager->setSystemMessage(m_config->systemMessage());

    // 连接 AI 理器的信号（使用 QueuedConnection 确保在主线程处理）
    connect(m_aiManager, &OpenAIManager::streamChunk,
            this, &ChatSession::onStreamChunk, Qt::QueuedConnection);
    connect(m_aiManager, &OpenAIManager::requestFinished,
            this, &ChatSession::onRequestFinished, Qt::QueuedConnection);
    connect(m_aiManager, &OpenAIManager::errorStringChanged,
            this, &ChatSession::onErrorChanged, Qt::QueuedConnection);

    // 非流式模式下，连接 messageReceived 信号
    connect(m_aiManager, &OpenAIManager::messageReceived,
            this, [this](const QString &response) {
                if (!m_aiManager->isStreamMode()) {
                    addAssistantMessage(response);
                }
            }, Qt::QueuedConnection);

    // Tool calls handler
    connect(m_aiManager, &OpenAIManager::toolCallsReceived,
            this, [this](const QJsonArray &toolCalls) {
                // Add placeholder message showing tool usage
                QString toolSummary;
                for (const auto &tc : toolCalls) {
                    QJsonObject call = tc.toObject();
                    QString name = call["function"].toObject()["name"].toString();
                    QJsonObject args = call["function"].toObject()["arguments"].toObject();
                    toolSummary += "[🔧 " + name + "(";
                    QStringList argStrs;
                    for (auto it = args.begin(); it != args.end(); ++it)
                        argStrs << it.key() + "=" + it.value().toString();
                    toolSummary += argStrs.join(", ") + ")]\n";
                }
                addAssistantMessage(toolSummary);

                // Submit tool results and continue the conversation
                m_aiManager->submitToolResults(toolCalls);
            }, Qt::QueuedConnection);

    // 监听配置变化，同步到 AI 管理器
    connect(m_config, &OpenAIConfig::apiKeyChanged, this, [this]() {
        m_aiManager->setApiKey(m_config->apiKey());
    });
    connect(m_config, &OpenAIConfig::baseUrlChanged, this, [this]() {
        m_aiManager->setBaseUrl(m_config->baseUrl());
    });
    connect(m_config, &OpenAIConfig::modelChanged, this, [this]() {
        m_aiManager->setModel(m_config->model());
    });
    connect(m_config, &OpenAIConfig::streamModeChanged, this, [this]() {
        m_aiManager->setStreamMode(m_config->streamMode());
    });
    connect(m_config, &OpenAIConfig::maxHistoryRoundsChanged, this, [this]() {
        m_aiManager->setMaxHistoryRounds(m_config->maxHistoryRounds());
    });
    connect(m_config, &OpenAIConfig::maxTokensChanged, this, [this]() {
        m_aiManager->setMaxTokens(m_config->maxTokens());
    });
    connect(m_config, &OpenAIConfig::reasoningEnabledChanged, this, [this]() {
        m_aiManager->setReasoningEnabled(m_config->reasoningEnabled());
    });
    connect(m_config, &OpenAIConfig::searchEnabledChanged, this, [this]() {
        m_aiManager->setSearchEnabled(m_config->searchEnabled());
    });
    connect(m_config, &OpenAIConfig::vendorCodeChanged, this, [this]() {
        m_aiManager->setVendorCode(m_config->vendorCode());
    });
    connect(m_config, &OpenAIConfig::systemMessageChanged, this, [this]() {
        m_aiManager->setSystemMessage(m_config->systemMessage());
    });
}

void ChatSession::syncHistoryToAI()
{
    m_aiManager->clearHistory();

    for (const auto *msg : m_messages) {
        if (msg->isStreaming()) continue;
        if (msg->content().isEmpty() && msg->attachments().isEmpty()) continue;
        m_aiManager->addMessageToHistory(msg->role(), msg->content(), msg->attachments());
    }
}

// ============= Getters =============
QString ChatSession::sessionId() const { return m_sessionId; }
QString ChatSession::title() const { return m_title; }
OpenAIConfig* ChatSession::config() const { return m_config; }
QList<ChatMessage*> ChatSession::messages() const {
    // Branch filtering: branchIndex 0 = original (pre-fork, shared across all branches)
    // Messages with branchIndex matching activeBranchIndex are shown
    QList<ChatMessage*> result;
    for (auto *msg : m_messages) {
        if (msg->branchIndex() == 0 || msg->branchIndex() == m_activeBranchIndex)
            result.append(msg);
    }
    return result;
}
int ChatSession::messageCount() const { return messages().size(); }
QDateTime ChatSession::createTime() const { return m_createTime; }
QDateTime ChatSession::updateTime() const { return m_updateTime; }
bool ChatSession::isActive() const { return m_isActive; }
bool ChatSession::isGenerating() const { return m_isGenerating; }
OpenAIManager* ChatSession::aiManager() const { return m_aiManager; }
bool ChatSession::isPinned() const { return m_pinned; }
QString ChatSession::group() const { return m_group; }
QStringList ChatSession::tags() const { return m_tags; }

void ChatSession::setPinned(bool pinned) {
    if (m_pinned != pinned) { m_pinned = pinned; emit pinnedChanged(); }
}
void ChatSession::setGroup(const QString &group) {
    if (m_group != group) { m_group = group; emit groupChanged(); }
}
void ChatSession::setTags(const QStringList &tags) {
    if (m_tags != tags) { m_tags = tags; emit tagsChanged(); }
}

int ChatSession::activeBranchIndex() const { return m_activeBranchIndex; }
void ChatSession::setActiveBranchIndex(int idx) {
    if (idx >= 0 && idx < m_branchCount && m_activeBranchIndex != idx) {
        m_activeBranchIndex = idx;
        emit activeBranchIndexChanged();
        emit messagesChanged();
        emit messageCountChanged();
    }
}
int ChatSession::branchCount() const { return m_branchCount; }

int ChatSession::forkAtMessage(int messageIndex)
{
    // Convert the "display" index (in the current branch) to the actual index in m_messages
    QList<ChatMessage*> visible = messages();
    if (messageIndex < 0 || messageIndex >= visible.size()) return -1;

    ChatMessage *forkMsg = visible.at(messageIndex);
    int realIndex = m_messages.indexOf(forkMsg);
    if (realIndex < 0) return -1;

    int newBranch = m_branchCount;
    m_branchCount++;
    m_activeBranchIndex = newBranch;

    // Mark all messages after the fork point in the original branch as branchIndex 0
    // (they stay visible in branch 0 only, but since 0 is shared, actually we
    // need to NOT mark them as branch 0, we leave them as-is with branchIndex=0.
    // Wait — the original branch messages already have branchIndex=0.
    // New messages will be tagged with branchIndex=newBranch.
    // The fork point message is at position realIndex. Messages after it in
    // branch 0 will still show up in branch 0 but not in the new branch — that's correct!)

    // Set fork message's parentMessageId as marker
    forkMsg->setParentMessageId("forked_to_branch_" + QString::number(newBranch));

    emit branchCountChanged();
    emit activeBranchIndexChanged();
    emit messagesChanged();
    emit messageCountChanged();

    return newBranch;
}

void ChatSession::switchBranch(int branchIndex)
{
    if (branchIndex >= 0 && branchIndex < m_branchCount) {
        setActiveBranchIndex(branchIndex);
        syncHistoryToAI();
    }
}

void ChatSession::deleteBranch(int branchIndex)
{
    if (branchIndex <= 0 || branchIndex >= m_branchCount) return;

    // Remove all messages with this branchIndex
    for (int i = m_messages.size() - 1; i >= 0; i--) {
        if (m_messages.at(i)->branchIndex() == branchIndex) {
            delete m_messages.takeAt(i);
        }
    }

    m_branchCount--;
    if (m_activeBranchIndex >= m_branchCount)
        m_activeBranchIndex = 0;

    emit branchCountChanged();
    emit activeBranchIndexChanged();
    emit messagesChanged();
    emit messageCountChanged();
    syncHistoryToAI();
}

// ============= Setters =============
void ChatSession::setTitle(const QString &title)
{
    if (m_title != title) {
        m_title = title;
        emit titleChanged();
        updateTimestamp();
    }
}

void ChatSession::setIsActive(bool active)
{
    if (m_isActive != active) {
        m_isActive = active;
        emit isActiveChanged();
    }
}

void ChatSession::updateTimestamp()
{
    m_updateTime = QDateTime::currentDateTime();
    emit updateTimeChanged();
}

// ============= 消息操作 =============
ChatMessage* ChatSession::addUserMessage(const QString &content)
{
    auto *msg = new ChatMessage(ChatMessage::UserRole, content, this);
    m_messages.append(msg);
    emit messageAdded(msg);
    emit messagesChanged();
    emit messageCountChanged();
    updateTimestamp();
    return msg;
}

ChatMessage* ChatSession::addAssistantMessage(const QString &content)
{
    auto *msg = new ChatMessage(ChatMessage::AssistantRole, content, this);
    m_messages.append(msg);
    emit messageAdded(msg);
    emit messagesChanged();
    emit messageCountChanged();
    updateTimestamp();
    return msg;
}

ChatMessage* ChatSession::createStreamingMessage()
{
    auto *msg = new ChatMessage(ChatMessage::AssistantRole, "", this);
    msg->setIsStreaming(true);
    // streamingContent 在构造函数中已初始化为空
    m_messages.append(msg);
    m_currentStreamingMessage = msg;
    emit messageAdded(msg);
    emit messagesChanged();
    emit messageCountChanged();
    updateTimestamp();
    return msg;
}

void ChatSession::clearMessages()
{
    qDeleteAll(m_messages);
    m_messages.clear();
    m_currentStreamingMessage = nullptr;
    emit messagesChanged();
    emit messageCountChanged();
    emit messagesCleared();
    updateTimestamp();
}

void ChatSession::deleteMessage(int index)
{
    if (index >= 0 && index < m_messages.size()) {
        auto *msg = m_messages.takeAt(index);
        if (m_currentStreamingMessage == msg) {
            m_currentStreamingMessage = nullptr;
        }
        msg->deleteLater();
        emit messageRemoved(index);
        emit messagesChanged();
        emit messageCountChanged();
        updateTimestamp();
    }
}

ChatMessage* ChatSession::messageAt(int index) const
{
    if (index >= 0 && index < m_messages.size())
        return m_messages.at(index);
    return nullptr;
}

ChatMessage* ChatSession::lastMessage() const
{
    if (!m_messages.isEmpty())
        return m_messages.last();
    return nullptr;
}

// ============= 核心方法：发送消息 =============
void ChatSession::sendMessage(const QString &content)
{
    if (m_isGenerating) {
        qWarning() << "Already generating, please wait or cancel";
        return;
    }

    if (content.trimmed().isEmpty()) {
        return;
    }

    // 1. 添加用户消息到列表
    auto *userMsg = addUserMessage(content);
    userMsg->setBranchIndex(m_activeBranchIndex);

    // 2. Inject web search context if available
    QString savedSystemMsg;
    if (m_aiManager->searchEnabled() && !m_webSearchContext.isEmpty()) {
        savedSystemMsg = m_aiManager->systemMessage();
        m_aiManager->setSystemMessage(savedSystemMsg + "\n\n[Web Search Results for: \"" + content + "\"]\n" + m_webSearchContext + "\nUse the above search results to inform your answer. Cite sources with URLs.");
    }

    // 3. 同步历史记录到 AI 管理器
    syncHistoryToAI();

    // 4. 创建流式消息占位（如果是流式模式）
    if (m_aiManager->isStreamMode()) {
        auto *streamMsg = createStreamingMessage();
        streamMsg->setBranchIndex(m_activeBranchIndex);
    }

    // 5. 设置生成状态
    m_isGenerating = true;
    emit isGeneratingChanged();
    emit generationStarted();

    // 6. 发送请求
    m_aiManager->sendMessage(content);

    // 7. Restore original system message and clear search context
    if (!savedSystemMsg.isEmpty()) {
        m_aiManager->setSystemMessage(savedSystemMsg);
    }
    m_webSearchContext.clear();
}

void ChatSession::setWebSearchContext(const QString &context)
{
    m_webSearchContext = context;
}

void ChatSession::sendMessageWithAttachments(const QString &content, const QVariantList &attachments)
{
    if (m_isGenerating) {
        qWarning() << "Already generating";
        return;
    }

    // 1. Add user message with attachments
    auto *msg = addUserMessage(content);
    msg->setAttachments(attachments);

    // 2. Sync history (includes attachment refs)
    syncHistoryToAI();

    // 3. Streaming placeholder
    if (m_aiManager->isStreamMode()) {
        createStreamingMessage();
    }

    // 4. Set generating state
    m_isGenerating = true;
    emit isGeneratingChanged();
    emit generationStarted();

    // 5. Send request
    m_aiManager->sendMessage(content);
}

void ChatSession::cancelGeneration()
{
    if (m_isGenerating && m_aiManager) {
        m_aiManager->cancelRequest();
        cleanupGeneration();
    }
}

void ChatSession::regenerateLastMessage()
{
    if (m_messages.size() < 2) return;

    // 找到最后一条用户消息
    int lastUserIndex = -1;
    QString lastUserContent;
    for (int i = m_messages.size() - 1; i >= 0; --i) {
        if (m_messages[i]->role() == "user") {
            lastUserIndex = i;
            lastUserContent = m_messages[i]->content();
            break;
        }
    }

    if (lastUserIndex < 0) return;

    // 删除这条用户消息之后的所有消息（包括 AI 回复）
    while (m_messages.size() > lastUserIndex + 1) {
        deleteMessage(m_messages.size() - 1);
    }

    // 重新发送
    sendMessage(lastUserContent);
}

void ChatSession::cleanupGeneration()
{
    m_isGenerating = false;
    emit isGeneratingChanged();

    if (m_currentStreamingMessage) {
        m_currentStreamingMessage->setIsStreaming(false);
        if (m_currentStreamingMessage->content().isEmpty()) {
            m_currentStreamingMessage->setContent("[生成已取消]");
        }
        m_currentStreamingMessage = nullptr;
    }
}

// ============= AI 回调槽函数 =============
void ChatSession::onStreamChunk(const QString &chunk)
{
    if (m_currentStreamingMessage) {
        m_currentStreamingMessage->appendStreamingContent(chunk);
    }
}

void ChatSession::onRequestFinished(bool success)
{
    if (m_aiManager->isStreamMode()) {
        // 流式模式：处理流式消息结束
        if (m_currentStreamingMessage) {
            m_currentStreamingMessage->setIsStreaming(false);
            // 流式结束后一次性渲染 markdown
            m_currentStreamingMessage->finalizeStreaming();
            if (!success && m_currentStreamingMessage->content().isEmpty()) {
                m_currentStreamingMessage->setContent("[生成失败]");
            }
            m_currentStreamingMessage = nullptr;
        }
    }
    // 非流式模式下，messageReceived 信号已经处理了添加消息

    cleanupGeneration();
    emit generationFinished(success, m_aiManager->errorString());
    updateTimestamp();
}

void ChatSession::onErrorChanged()
{
    if (!m_aiManager->errorString().isEmpty()) {
        qWarning() << "AI Error:" << m_aiManager->errorString();
    }
}

// ============= 历史记录管理 =============
void ChatSession::trimHistory(int maxRounds)
{
    int rounds = m_messages.size() / 2;
    while (rounds > maxRounds && m_messages.size() >= 2) {
        deleteMessage(0);
        deleteMessage(0);
        rounds--;
    }
    syncHistoryToAI();
}

void ChatSession::trimHistoryToSize(int maxMessages)
{
    while (m_messages.size() > maxMessages) {
        deleteMessage(0);
    }
    syncHistoryToAI();
}

QVariantMap ChatSession::getContextUsage() const
{
    QVariantMap usage;
    int maxWindow = m_config->contextWindowSize();

    qint64 totalChars = 0;
    for (const auto *msg : m_messages) {
        totalChars += msg->content().length();
    }
    // Also count system message
    totalChars += m_config->systemMessage().length();

    // Rough estimate: Chinese chars ~2.5 per token, English ~4 per token
    int chineseChars = 0;
    int otherChars = 0;
    for (const auto &ch : QString::fromUtf8("")) {
        Q_UNUSED(ch)
    }
    // Use simpler heuristic: detect CJK range
    auto countForToken = [](const QString &text) -> qint64 {
        qint64 tokens = 0;
        qint64 cn = 0;
        for (const QChar &c : text) {
            ushort u = c.unicode();
            if (u >= 0x4E00 && u <= 0x9FFF) cn++;
        }
        qint64 other = text.length() - cn;
        tokens = cn / 2 + other / 4 + 1;
        return tokens;
    };

    qint64 estimatedTokens = countForToken(m_config->systemMessage());
    for (const auto *msg : m_messages) {
        estimatedTokens += countForToken(msg->content());
    }

    double pct = maxWindow > 0 ? (double)estimatedTokens / maxWindow * 100.0 : 0;

    usage["estimatedTokens"] = QVariant::fromValue(estimatedTokens);
    usage["maxTokens"] = maxWindow;
    usage["percentage"] = QString::number(qMin(pct, 100.0), 'f', 1);
    usage["isWarning"] = pct >= 60.0;
    usage["isCritical"] = pct >= 80.0;
    usage["messageCount"] = m_messages.size();

    return usage;
}

void ChatSession::compressContextIfNeeded(double threshold)
{
    auto usage = getContextUsage();
    double pct = usage["percentage"].toString().toDouble();
    if (pct < threshold * 100.0) return;

    // Keep last 4 messages (2 rounds), summarize older ones
    if (m_messages.size() <= 4) return;

    // Build summary of older messages and replace them
    QString summary = "前序对话概要：\n";
    int keepFrom = m_messages.size() - 4;
    for (int i = 0; i < keepFrom; i++) {
        auto *msg = m_messages.at(i);
        QString role = msg->role() == "user" ? "用户" : "AI";
        summary += role + ": " + msg->content().left(200) + "\n";
    }

    // Delete old messages from front
    for (int i = 0; i < keepFrom; i++) {
        deleteMessage(0);
    }

    // Insert summary as system-style message
    auto *summaryMsg = new ChatMessage(ChatMessage::UserRole, summary, this);
    m_messages.prepend(summaryMsg);

    syncHistoryToAI();
    emit messagesChanged();
}

QJsonArray ChatSession::buildApiMessages() const
{
    QJsonArray arr;

    QJsonObject sysMsg;
    sysMsg["role"] = "system";
    sysMsg["content"] = m_config->systemMessage();
    arr.append(sysMsg);

    for (const auto *msg : m_messages) {
        if (msg->isStreaming()) continue;
        if (msg->content().isEmpty()) continue;

        QJsonObject obj;
        obj["role"] = msg->role();
        obj["content"] = msg->content();
        arr.append(obj);
    }

    return arr;
}

// ============= 刷新和更新 =============
void ChatSession::refreshMessages()
{
    emit messagesChanged();
    emit messageCountChanged();
}

void ChatSession::updateMessage(int index, const QString &content)
{
    if (index >= 0 && index < m_messages.size()) {
        m_messages.at(index)->setContent(content);
        emit messageUpdated(index);
        emit messagesChanged();
        updateTimestamp();
    }
}

// ============= 序列化 =============
void ChatSession::loadFromJson(const QJsonObject &obj)
{
    m_sessionId = obj["sessionId"].toString();
    if (m_sessionId.isEmpty()) m_sessionId = generateId();

    m_title = obj["title"].toString("新对话");
    m_createTime = QDateTime::fromString(obj["createTime"].toString(), Qt::ISODate);
    m_updateTime = QDateTime::fromString(obj["updateTime"].toString(), Qt::ISODate);

    m_config->loadFromJson(obj["config"].toObject());

    m_pinned = obj["pinned"].toBool(false);
    m_group = obj["group"].toString();
    m_tags = obj["tags"].toVariant().toStringList();
    m_activeBranchIndex = obj["activeBranchIndex"].toInt(0);
    m_branchCount = obj["branchCount"].toInt(1);

    QJsonArray msgArr = obj["messages"].toArray();
    for (const auto &val : msgArr) {
        auto *msg = new ChatMessage(ChatMessage::UserRole, "", this);
        msg->loadFromJson(val.toObject());
        m_messages.append(msg);
    }


    syncHistoryToAI();

    emit messagesChanged();
    emit messageCountChanged();
}

QJsonObject ChatSession::toJson() const
{
    QJsonObject obj;
    obj["sessionId"] = m_sessionId;
    obj["title"] = m_title;
    obj["createTime"] = m_createTime.toString(Qt::ISODate);
    obj["updateTime"] = m_updateTime.toString(Qt::ISODate);
    obj["config"] = m_config->toJson();
    obj["pinned"] = m_pinned;
    obj["activeBranchIndex"] = m_activeBranchIndex;
    obj["branchCount"] = m_branchCount;
    if (!m_group.isEmpty()) obj["group"] = m_group;
    if (!m_tags.isEmpty()) obj["tags"] = QJsonArray::fromStringList(m_tags);

    QJsonArray msgArr;
    for (const auto *msg : m_messages) {
        msgArr.append(msg->toJson());
    }
    obj["messages"] = msgArr;

    return obj;
}
