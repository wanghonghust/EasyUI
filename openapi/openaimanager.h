#ifndef OPENAI_MANAGER_H
#define OPENAI_MANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonArray>
#include <qqml.h>

struct ChatMsg{
    QString role;
    QString content;
    QVariantList attachments; // { {type, mimeType, path, data(base64)} }
};

class OpenAIManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString apiKey READ apiKey WRITE setApiKey NOTIFY apiKeyChanged)
    Q_PROPERTY(QString baseUrl READ baseUrl WRITE setBaseUrl NOTIFY baseUrlChanged)
    Q_PROPERTY(QString model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)
    Q_PROPERTY(bool isStreamMode READ isStreamMode WRITE setStreamMode NOTIFY streamModeChanged)
    Q_PROPERTY(int maxHistoryRounds READ maxHistoryRounds WRITE setMaxHistoryRounds NOTIFY maxHistoryRoundsChanged)
    Q_PROPERTY(int maxTokens READ maxTokens WRITE setMaxTokens NOTIFY maxTokensChanged)
    Q_PROPERTY(bool reasoningEnabled READ reasoningEnabled WRITE setReasoningEnabled NOTIFY reasoningEnabledChanged)
    Q_PROPERTY(bool searchEnabled READ searchEnabled WRITE setSearchEnabled NOTIFY searchEnabledChanged)
    Q_PROPERTY(QString vendorCode READ vendorCode WRITE setVendorCode NOTIFY vendorCodeChanged)

public:
    // static OpenAIManager* instance();
    explicit OpenAIManager(QObject *parent = nullptr);
    ~OpenAIManager();
    OpenAIManager(const OpenAIManager&) = delete;
    OpenAIManager& operator=(const OpenAIManager&) = delete;

    QString apiKey() const;
    void setApiKey(const QString &key);
    QString baseUrl() const;
    void setBaseUrl(const QString &url);
    QString model() const;
    void setModel(const QString &model);
    bool isLoading() const;
    QString errorString() const;
    bool isStreamMode() const;
    void setStreamMode(bool stream);
    int maxHistoryRounds() const;
    void setMaxHistoryRounds(int rounds);
    int maxTokens() const;
    void setMaxTokens(int tokens);
    bool reasoningEnabled() const;
    void setReasoningEnabled(bool enabled);
    bool searchEnabled() const;
    void setSearchEnabled(bool enabled);
    QString vendorCode() const;
    void setVendorCode(const QString &code);

    Q_INVOKABLE void sendMessage(const QString &message);
    Q_INVOKABLE void submitToolResults(const QJsonArray &toolResults);
    Q_INVOKABLE void cancelRequest();
    Q_INVOKABLE void clearError();
    Q_INVOKABLE void clearHistory();
    Q_INVOKABLE void setSystemMessage(const QString &message);
    QString systemMessage() const { return m_systemMessage; }

signals:
    void apiKeyChanged();
    void baseUrlChanged();
    void modelChanged();
    void isLoadingChanged();
    void errorStringChanged();
    void streamModeChanged();
    void maxHistoryRoundsChanged();
    void maxTokensChanged();
    void reasoningEnabledChanged();
    void searchEnabledChanged();
    void vendorCodeChanged();
    void messageReceived(const QString &response);
    void streamChunk(const QString &chunk);
    void requestFinished(bool success);
    void toolCallsReceived(const QJsonArray &toolCalls);

private:

    QNetworkAccessManager *m_manager;
    QNetworkReply *m_reply;
    QString m_apiKey;
    QString m_baseUrl;
    QString m_model;
    bool m_isLoading;
    QString m_errorString;
    bool m_isStreamMode;

    QList<ChatMsg> m_history;
    QString m_systemMessage;
    int m_maxHistoryRounds;
    int m_maxTokens;
    bool m_reasoningEnabled = false;
    bool m_searchEnabled = false;
    QString m_vendorCode;
    QJsonArray m_pendingToolCalls; // accumulated while streaming
    int m_maxToolIterations = 10;
    QString m_streamBuffer;  // 流式消息累积缓冲区
    QString m_reasoningBuffer; // 流式思考内容累积缓冲区

    void setIsLoading(bool loading);
    void setErrorString(const QString &error);
    QString fullUrl() const;
    QJsonObject buildRequestBody(const QString &message);
    void handleStreamData();
    void handleResponse();
    void trimHistory();
    QJsonArray buildMessagesArray() const;
    QJsonArray buildToolsArray() const;
    void processToolCalls(const QJsonArray &toolCalls);
public:
    void addMessageToHistory(const QString &role, const QString &content, const QVariantList &attachments = QVariantList());
};


#endif
