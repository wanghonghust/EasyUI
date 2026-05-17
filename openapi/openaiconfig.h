#ifndef OPENAI_CONFIG_H
#define OPENAI_CONFIG_H

#include <QObject>
#include <QJsonObject>
#include <qqml.h>

class OpenAIConfig : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Use ChatManager to create sessions")

    // 配置属性
    Q_PROPERTY(QString apiKey READ apiKey WRITE setApiKey NOTIFY apiKeyChanged)
    Q_PROPERTY(QString baseUrl READ baseUrl WRITE setBaseUrl NOTIFY baseUrlChanged)
    Q_PROPERTY(QString model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(QString systemMessage READ systemMessage WRITE setSystemMessage NOTIFY systemMessageChanged)
    Q_PROPERTY(bool streamMode READ streamMode WRITE setStreamMode NOTIFY streamModeChanged)
    Q_PROPERTY(int maxHistoryRounds READ maxHistoryRounds WRITE setMaxHistoryRounds NOTIFY maxHistoryRoundsChanged)
    Q_PROPERTY(double temperature READ temperature WRITE setTemperature NOTIFY temperatureChanged)
    Q_PROPERTY(int maxTokens READ maxTokens WRITE setMaxTokens NOTIFY maxTokensChanged)
    Q_PROPERTY(bool reasoningEnabled READ reasoningEnabled WRITE setReasoningEnabled NOTIFY reasoningEnabledChanged)
    Q_PROPERTY(bool searchEnabled READ searchEnabled WRITE setSearchEnabled NOTIFY searchEnabledChanged)
    Q_PROPERTY(QString vendorCode READ vendorCode WRITE setVendorCode NOTIFY vendorCodeChanged)
    Q_PROPERTY(int contextWindowSize READ contextWindowSize WRITE setContextWindowSize NOTIFY contextWindowSizeChanged)

public:
    explicit OpenAIConfig(QObject *parent = nullptr);

    // 从 JSON 加载/保存
    void loadFromJson(const QJsonObject &obj);
    QJsonObject toJson() const;

    // 复制配置
    Q_INVOKABLE OpenAIConfig* clone(QObject *parent = nullptr) const;

    // Getters
    QString apiKey() const;
    QString baseUrl() const;
    QString model() const;
    QString systemMessage() const;
    bool streamMode() const;
    int maxHistoryRounds() const;
    double temperature() const;
    int maxTokens() const;
    bool reasoningEnabled() const;
    bool searchEnabled() const;
    QString vendorCode() const;
    int contextWindowSize() const;

    // Setters
    void setApiKey(const QString &key);
    void setBaseUrl(const QString &url);
    void setModel(const QString &model);
    void setSystemMessage(const QString &msg);
    void setStreamMode(bool enabled);
    void setMaxHistoryRounds(int rounds);
    void setTemperature(double temp);
    void setMaxTokens(int tokens);
    void setReasoningEnabled(bool enabled);
    void setSearchEnabled(bool enabled);
    void setVendorCode(const QString &code);
    void setContextWindowSize(int tokens);

signals:
    void apiKeyChanged();
    void baseUrlChanged();
    void modelChanged();
    void systemMessageChanged();
    void streamModeChanged();
    void maxHistoryRoundsChanged();
    void temperatureChanged();
    void maxTokensChanged();
    void reasoningEnabledChanged();
    void searchEnabledChanged();
    void vendorCodeChanged();
    void contextWindowSizeChanged();

private:
    QString m_apiKey;
    QString m_baseUrl;
    QString m_model;
    QString m_systemMessage;
    bool m_streamMode;
    int m_maxHistoryRounds;
    double m_temperature;
    int m_maxTokens;
    bool m_reasoningEnabled = false;
    bool m_searchEnabled = false;
    QString m_vendorCode;
    int m_contextWindowSize = 128000;
};

#endif
