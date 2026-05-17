#include "openaimanager.h"
#include "toolregistry.h"
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QRegularExpression>


OpenAIManager::OpenAIManager(QObject *parent)
    : QObject(parent)
    , m_manager(new QNetworkAccessManager(this))
    , m_reply(nullptr)
    , m_baseUrl("https://api.openai.com")
    , m_model("gpt-4o-mini")
    , m_isLoading(false)
    , m_isStreamMode(true)
    , m_maxHistoryRounds(30)  // 增大默认上下文：30轮对话
    , m_maxTokens(8192)  // 默认 max_tokens：8K
{
    m_systemMessage = "You are a helpful AI assistant.";
}

OpenAIManager::~OpenAIManager()
{
    cancelRequest();
}

QString OpenAIManager::apiKey() const { return m_apiKey; }
QString OpenAIManager::baseUrl() const { return m_baseUrl; }
QString OpenAIManager::model() const { return m_model; }
bool OpenAIManager::isLoading() const { return m_isLoading; }
QString OpenAIManager::errorString() const { return m_errorString; }
bool OpenAIManager::isStreamMode() const { return m_isStreamMode; }
int OpenAIManager::maxHistoryRounds() const { return m_maxHistoryRounds; }
int OpenAIManager::maxTokens() const { return m_maxTokens; }
bool OpenAIManager::reasoningEnabled() const { return m_reasoningEnabled; }
bool OpenAIManager::searchEnabled() const { return m_searchEnabled; }

void OpenAIManager::setApiKey(const QString &key) {
    if (m_apiKey != key) { m_apiKey = key; emit apiKeyChanged(); }
}
void OpenAIManager::setBaseUrl(const QString &url) {
    QString normalized = url;
    while (normalized.endsWith("/")) normalized.chop(1);
    if (m_baseUrl != normalized) { m_baseUrl = normalized; emit baseUrlChanged(); }
}
void OpenAIManager::setModel(const QString &model) {
    if (m_model != model) { m_model = model; emit modelChanged(); }
}
void OpenAIManager::setStreamMode(bool stream) {
    if (m_isStreamMode != stream) { m_isStreamMode = stream; emit streamModeChanged(); }
}
void OpenAIManager::setMaxHistoryRounds(int rounds) {
    if (m_maxHistoryRounds != rounds && rounds > 0) {
        m_maxHistoryRounds = rounds;
        emit maxHistoryRoundsChanged();
        trimHistory();
    }
}
void OpenAIManager::setMaxTokens(int tokens) {
    if (m_maxTokens != tokens && tokens > 0) {
        m_maxTokens = tokens;
        emit maxTokensChanged();
    }
}
void OpenAIManager::setReasoningEnabled(bool enabled) {
    if (m_reasoningEnabled != enabled) {
        m_reasoningEnabled = enabled;
        emit reasoningEnabledChanged();
    }
}
void OpenAIManager::setSearchEnabled(bool enabled) {
    if (m_searchEnabled != enabled) {
        m_searchEnabled = enabled;
        emit searchEnabledChanged();
    }
}
QString OpenAIManager::vendorCode() const { return m_vendorCode; }
void OpenAIManager::setVendorCode(const QString &code) {
    if (m_vendorCode != code) { m_vendorCode = code; emit vendorCodeChanged(); }
}
void OpenAIManager::setIsLoading(bool loading) {
    if (m_isLoading != loading) { m_isLoading = loading; emit isLoadingChanged(); }
}
void OpenAIManager::setErrorString(const QString &error) {
    m_errorString = error;
    qDebug() << "Error:" << error;
    emit errorStringChanged();
}
QString OpenAIManager::fullUrl() const {
    if (m_vendorCode == "ollama")
        return m_baseUrl + "/api/chat";
    // OpenAI-compatible vendors: baseUrl already includes the full path
    return m_baseUrl;
}

// ========== 历史记录管理 ==========

void OpenAIManager::addMessageToHistory(const QString &role, const QString &content, const QVariantList &attachments) {
    m_history.append({role, content, attachments});
    trimHistory();
}

void OpenAIManager::trimHistory() {
    int rounds = 0;
    for (const auto &m : std::as_const(m_history)) {
        if (m.role == "user" || m.role == "assistant") rounds++;
    }
    rounds /= 2;

    while (rounds > m_maxHistoryRounds && m_history.size() >= 2) {
        int removed = 0;
        for (int i = 0; i < m_history.size() && removed < 2; ++i) {
            if (m_history[i].role == "user" || m_history[i].role == "assistant") {
                m_history.removeAt(i--);
                removed++;
            }
        }
        rounds--;
    }
}

QJsonArray OpenAIManager::buildMessagesArray() const {
    QJsonArray messages;
    QJsonObject sys;
    sys["role"] = "system";
    sys["content"] = m_systemMessage;
    messages.append(sys);

    for (const auto &m : m_history) {
        QJsonObject obj;
        obj["role"] = m.role;

        if (!m.attachments.isEmpty()) {
            // Multimodal content: array of text + image_url parts
            QJsonArray contentParts;
            QJsonObject textPart;
            textPart["type"] = "text";
            textPart["text"] = m.content;
            contentParts.append(textPart);

            for (const auto &att : m.attachments) {
                QVariantMap am = att.toMap();
                if (am["type"].toString() == "image" && !am["data"].toString().isEmpty()) {
                    QJsonObject imgPart;
                    imgPart["type"] = "image_url";
                    QJsonObject imgUrl;
                    imgUrl["url"] = am["data"].toString(); // data:image/png;base64,...
                    if (!am["mimeType"].toString().isEmpty())
                        imgUrl["detail"] = "auto";
                    imgPart["image_url"] = imgUrl;
                    contentParts.append(imgPart);
                }
            }
            obj["content"] = contentParts;
        } else {
            QString content = m.content;
            if (!m_reasoningEnabled) {
                content.replace(QRegularExpression("<think>[\\s\\S]*?</think>"), "");
                content = content.trimmed();
            }
            obj["content"] = content;
        }
        messages.append(obj);
    }
    return messages;
}

void OpenAIManager::clearHistory() {
    m_history.clear();
    m_streamBuffer.clear();
    m_reasoningBuffer.clear();
    qDebug() << "History cleared";
}

void OpenAIManager::setSystemMessage(const QString &message) {
    m_systemMessage = message;
}

// ========== 网络请求 ==========

QJsonObject OpenAIManager::buildRequestBody(const QString &message) {
    QJsonObject json;
    json["model"] = m_model;
    json["stream"] = m_isStreamMode;
    json["temperature"] = 0.7;
    json["max_tokens"] = m_maxTokens;

    json["enable_thinking"] = m_reasoningEnabled;
    json["enable_search"] = m_searchEnabled;

    // Add tools if available
    QJsonArray tools = buildToolsArray();
    if (!tools.isEmpty()) json["tools"] = tools;

    addMessageToHistory("user", message);
    json["messages"] = buildMessagesArray();

    return json;
}

QJsonArray OpenAIManager::buildToolsArray() const {
    auto *registry = ToolRegistry::create(nullptr, nullptr);
    QVariantList defs = registry->getToolDefinitions();
    QJsonArray tools;
    for (const auto &d : defs)
        tools.append(QJsonObject::fromVariantMap(d.toMap()));
    return tools;
}

void OpenAIManager::sendMessage(const QString &message) {
    if (m_apiKey.isEmpty()) {
        setErrorString("API Key 未设置");
        emit requestFinished(false);
        return;
    }
    if (m_baseUrl.isEmpty()) {
        setErrorString("API URL 未设置");
        emit requestFinished(false);
        return;
    }

    cancelRequest();
    m_streamBuffer.clear();  // 清空流式缓冲区
    m_reasoningBuffer.clear(); // 清空思考缓冲区

    auto url = fullUrl();
    QNetworkRequest req{QUrl(url)};
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    req.setRawHeader("Authorization", ("Bearer " + m_apiKey).toUtf8());

    QJsonDocument doc(buildRequestBody(message));
    setIsLoading(true);
    clearError();

    m_reply = m_manager->post(req, doc.toJson());

    if (m_isStreamMode) {
        connect(m_reply, &QNetworkReply::readyRead, this, &OpenAIManager::handleStreamData);
    }
    connect(m_reply, &QNetworkReply::finished, this, &OpenAIManager::handleResponse);
}

void OpenAIManager::submitToolResults(const QJsonArray &toolResults)
{
    // Add assistant message with tool_calls to history
    QJsonObject assistantMsg;
    assistantMsg["role"] = "assistant";
    assistantMsg["tool_calls"] = toolResults;
    addMessageToHistory("assistant", "[tool_calls]");

    // Add tool result messages
    auto *registry = ToolRegistry::create(nullptr, nullptr);
    for (const auto &tc : toolResults) {
        QJsonObject call = tc.toObject();
        QString funcName = call["function"].toObject()["name"].toString();
        QJsonObject funcArgs = call["function"].toObject()["arguments"].toObject();

        QVariantMap result = registry->executeTool(funcName, funcArgs);
        QJsonObject resultObj = QJsonObject::fromVariantMap(result);
        QString resultStr = QJsonDocument(resultObj).toJson(QJsonDocument::Compact);

        QJsonObject toolMsg;
        toolMsg["role"] = "tool";
        toolMsg["tool_call_id"] = call["id"].toString();
        toolMsg["content"] = resultStr;
        // Store as ChatMsg for history
        m_history.append({"tool", resultStr, {}});
    }

    // Re-send the conversation (without a new user message)
    setIsLoading(true);
    clearError();

    QJsonObject json;
    json["model"] = m_model;
    json["stream"] = false; // force non-stream for tool responses
    json["temperature"] = 0.7;
    json["max_tokens"] = m_maxTokens;
    json["enable_thinking"] = m_reasoningEnabled;

    QJsonArray tools = buildToolsArray();
    if (!tools.isEmpty()) json["tools"] = tools;

    json["messages"] = buildMessagesArray();

    QString url = fullUrl();
    QNetworkRequest req{QUrl(url)};
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    req.setRawHeader("Authorization", ("Bearer " + m_apiKey).toUtf8());

    QJsonDocument doc(json);
    m_reply = m_manager->post(req, doc.toJson());
    connect(m_reply, &QNetworkReply::finished, this, &OpenAIManager::handleResponse);
}

void OpenAIManager::handleStreamData() {
    if (!m_reply || !m_reply->isOpen()) return;

    QByteArray data = m_reply->readAll();
    QJsonDocument res = QJsonDocument::fromJson(data);
    QString chunk = QString::fromUtf8(data);


    if(!res.isNull()){
        qDebug() << res ;
    }

    for (const QString &line : chunk.split("\n")) {
        QString trimmed = line.trimmed();
        if (!trimmed.startsWith("data: ")) continue;

        QString jsonStr = trimmed.mid(6);
        if (jsonStr == "[DONE]") continue;

        QJsonDocument doc = QJsonDocument::fromJson(jsonStr.toUtf8());
        if (doc.isNull()) continue;

        QJsonObject obj = doc.object();
        QJsonArray choices = obj["choices"].toArray();
        if (choices.isEmpty()) continue;

        QJsonObject delta = choices[0].toObject()["delta"].toObject();
        QString content = delta["content"].toString();
        QString reasoning = delta["reasoning_content"].toString();

        if (!reasoning.isEmpty()) {
            // 第一个 reasoning chunk 时先输出 <think> 标签开头
            if (m_reasoningBuffer.isEmpty()) {
                emit streamChunk("<think>\n");
            }
            m_reasoningBuffer += reasoning;
            emit streamChunk(reasoning);
        }
        if (!content.isEmpty()) {
            // 从 reasoning 切换到 content 时，关闭 <think> 标签
            if (!m_reasoningBuffer.isEmpty() && m_streamBuffer.isEmpty()) {
                emit streamChunk("\n</think>\n\n");
            }
            m_streamBuffer += content;  // 累积
            emit streamChunk(content);
        }
    }
}

void OpenAIManager::handleResponse() {
    if (!m_reply) return;

    setIsLoading(false);
    bool success = false;

    if (m_reply->error() != QNetworkReply::NoError &&
        m_reply->error() != QNetworkReply::OperationCanceledError) {
        // 主动取消（abort）时 error 为 OperationCanceledError，静默处理
        QString err = m_reply->errorString();
        if (m_reply->isOpen()) {
            QByteArray data = m_reply->readAll();
            QJsonDocument errDoc = QJsonDocument::fromJson(data);
            if (!errDoc.isNull()) {
                QString msg = errDoc.object()["error"].toObject()["message"].toString();
                if (!msg.isEmpty()) err = msg;
            }
        }
        setErrorString(err);
    } else if (m_reply->error() == QNetworkReply::OperationCanceledError) {
        // 用户主动取消，不报错，静默结束
        m_reply->deleteLater();
        m_reply = nullptr;
        emit requestFinished(false);
        return;
    } else if (!m_isStreamMode) {
        QByteArray data = m_reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(data);

        if (doc.isNull()) {
            setErrorString("JSON 解析失败");
        } else {
            QJsonArray choices = doc.object()["choices"].toArray();
            if (!choices.isEmpty()) {
                QJsonObject choice = choices[0].toObject();
                QJsonObject message = choice["message"].toObject();

                // Check for tool_calls first
                QJsonArray toolCalls = message["tool_calls"].toArray();
                if (!toolCalls.isEmpty()) {
                    emit toolCallsReceived(toolCalls);
                    success = true;
                } else {
                    QString content = message["content"].toString();
                    QString reasoning = message["reasoning_content"].toString();
                    QString fullContent = content;
                    if (!reasoning.isEmpty()) {
                        fullContent = "<think>\n" + reasoning + "\n</think>\n\n" + content;
                    }
                    addMessageToHistory("assistant", fullContent);
                    emit messageReceived(fullContent);
                    success = true;
                }
            } else {
                setErrorString("响应为空");
            }
        }
    } else {
        // 流式结束，保存累积的完整回复
        QString fullContent = m_streamBuffer;
        // 如果有思考内容，包装成 <think> 标签放在前面
        if (!m_reasoningBuffer.isEmpty()) {
            fullContent = "<think>\n" + m_reasoningBuffer + "\n</think>\n\n" + fullContent;
        }
        if (!fullContent.isEmpty()) {
            addMessageToHistory("assistant", fullContent);
            qDebug() << "Stream finished。 ";
        }
        success = true;
    }

    m_reply->deleteLater();
    m_reply = nullptr;
    emit requestFinished(success);
}

void OpenAIManager::cancelRequest() {
    if (m_reply) {
        // 先断开所有信号，防止 abort() 触发 finished/readyRead 再次进入回调
        m_reply->disconnect(this);
        m_reply->abort();
        m_reply->deleteLater();
        m_reply = nullptr;
        setIsLoading(false);
    }
}

void OpenAIManager::clearError() {
    setErrorString("");
}
