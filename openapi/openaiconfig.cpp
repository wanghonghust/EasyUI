#include "openaiconfig.h"

OpenAIConfig::OpenAIConfig(QObject *parent)
    : QObject(parent)
    , m_baseUrl("https://api.openai.com/v1/chat/completions")
    , m_model("gpt-4o-mini")
    , m_systemMessage("You are a helpful assistant.")
    , m_streamMode(true)
    , m_maxHistoryRounds(30)  // 增大默认上下文：30轮对话
    , m_temperature(0.7)
    , m_maxTokens(8192)  // 默认 max_tokens：8K
{
}

void OpenAIConfig::loadFromJson(const QJsonObject &obj)
{
    m_apiKey = obj["apiKey"].toString();
    m_baseUrl = obj["baseUrl"].toString(m_baseUrl);
    m_model = obj["model"].toString(m_model);
    m_systemMessage = obj["systemMessage"].toString(m_systemMessage);
    m_streamMode = obj["streamMode"].toBool(m_streamMode);
    m_maxHistoryRounds = obj["maxHistoryRounds"].toInt(m_maxHistoryRounds);
    m_temperature = obj["temperature"].toDouble(m_temperature);
    m_maxTokens = obj["maxTokens"].toInt(m_maxTokens);
    m_reasoningEnabled = obj["reasoningEnabled"].toBool(m_reasoningEnabled);
    m_searchEnabled = obj["searchEnabled"].toBool(m_searchEnabled);
    m_vendorCode = obj["vendorCode"].toString();
    m_contextWindowSize = obj["contextWindowSize"].toInt(m_contextWindowSize);
}

QJsonObject OpenAIConfig::toJson() const
{
    QJsonObject obj;
    obj["apiKey"] = m_apiKey;
    obj["baseUrl"] = m_baseUrl;
    obj["model"] = m_model;
    obj["systemMessage"] = m_systemMessage;
    obj["streamMode"] = m_streamMode;
    obj["maxHistoryRounds"] = m_maxHistoryRounds;
    obj["temperature"] = m_temperature;
    obj["maxTokens"] = m_maxTokens;
    obj["reasoningEnabled"] = m_reasoningEnabled;
    obj["searchEnabled"] = m_searchEnabled;
    if (!m_vendorCode.isEmpty()) obj["vendorCode"] = m_vendorCode;
    obj["contextWindowSize"] = m_contextWindowSize;
    return obj;
}

OpenAIConfig* OpenAIConfig::clone(QObject *parent) const
{
    auto *copy = new OpenAIConfig(parent);
    copy->m_apiKey = m_apiKey;
    copy->m_baseUrl = m_baseUrl;
    copy->m_model = m_model;
    copy->m_systemMessage = m_systemMessage;
    copy->m_streamMode = m_streamMode;
    copy->m_maxHistoryRounds = m_maxHistoryRounds;
    copy->m_temperature = m_temperature;
    copy->m_maxTokens = m_maxTokens;
    copy->m_reasoningEnabled = m_reasoningEnabled;
    copy->m_searchEnabled = m_searchEnabled;
    copy->m_vendorCode = m_vendorCode;
    copy->m_contextWindowSize = m_contextWindowSize;
    return copy;
}

// Getters
QString OpenAIConfig::apiKey() const { return m_apiKey; }
QString OpenAIConfig::baseUrl() const { return m_baseUrl; }
QString OpenAIConfig::model() const { return m_model; }
QString OpenAIConfig::systemMessage() const { return m_systemMessage; }
bool OpenAIConfig::streamMode() const { return m_streamMode; }
int OpenAIConfig::maxHistoryRounds() const { return m_maxHistoryRounds; }
double OpenAIConfig::temperature() const { return m_temperature; }
int OpenAIConfig::maxTokens() const { return m_maxTokens; }
bool OpenAIConfig::reasoningEnabled() const { return m_reasoningEnabled; }
bool OpenAIConfig::searchEnabled() const { return m_searchEnabled; }

// Setters
void OpenAIConfig::setApiKey(const QString &key) {
    if (m_apiKey != key) { m_apiKey = key; emit apiKeyChanged(); }
}
void OpenAIConfig::setBaseUrl(const QString &url) {
    QString normalized = url;
    while (normalized.endsWith("/")) normalized.chop(1);
    if (m_baseUrl != normalized) { m_baseUrl = normalized; emit baseUrlChanged(); }
}
void OpenAIConfig::setModel(const QString &model) {
    if (m_model != model) { m_model = model; emit modelChanged(); }
}
void OpenAIConfig::setSystemMessage(const QString &msg) {
    if (m_systemMessage != msg) { m_systemMessage = msg; emit systemMessageChanged(); }
}
void OpenAIConfig::setStreamMode(bool enabled) {
    if (m_streamMode != enabled) { m_streamMode = enabled; emit streamModeChanged(); }
}
void OpenAIConfig::setMaxHistoryRounds(int rounds) {
    if (m_maxHistoryRounds != rounds && rounds > 0) {
        m_maxHistoryRounds = rounds;
        emit maxHistoryRoundsChanged();
    }
}
void OpenAIConfig::setTemperature(double temp) {
    if (!qFuzzyCompare(m_temperature, temp)) {
        m_temperature = qBound(0.0, temp, 2.0);
        emit temperatureChanged();
    }
}

void OpenAIConfig::setMaxTokens(int tokens) {
    if (m_maxTokens != tokens && tokens > 0) {
        m_maxTokens = tokens;
        emit maxTokensChanged();
    }
}

void OpenAIConfig::setReasoningEnabled(bool enabled) {
    if (m_reasoningEnabled != enabled) {
        m_reasoningEnabled = enabled;
        emit reasoningEnabledChanged();
    }
}

void OpenAIConfig::setSearchEnabled(bool enabled) {
    if (m_searchEnabled != enabled) {
        m_searchEnabled = enabled;
        emit searchEnabledChanged();
    }
}

QString OpenAIConfig::vendorCode() const { return m_vendorCode; }
void OpenAIConfig::setVendorCode(const QString &code) {
    if (m_vendorCode != code) { m_vendorCode = code; emit vendorCodeChanged(); }
}

int OpenAIConfig::contextWindowSize() const { return m_contextWindowSize; }
void OpenAIConfig::setContextWindowSize(int tokens) {
    if (m_contextWindowSize != tokens && tokens > 0) {
        m_contextWindowSize = tokens;
        emit contextWindowSizeChanged();
    }
}
