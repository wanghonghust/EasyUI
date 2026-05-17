#ifndef MODELCONFIGMANAGER_H
#define MODELCONFIGMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QJsonObject>
#include <QMutex>
#include <QDateTime>
#include <QQmlEngine>

// 前向声明
class QByteArray;
class QString;

// === 数据结构 ===
struct ModelVendor {
    int id = -1;
    QString code;
    QString name;
    QString website;
    QString apiDocsUrl;
    QString defaultBaseUrl;
    bool isOfficial = true;
};

struct ApiKey {
    int id = -1;
    int vendorId = -1;
    QString name;
    QString keyMask;
    bool isEnabled = true;
    bool isDefault = false;
    int rateLimitPerMinute = 0;
    double monthlyBudgetUsd = 0.0;
    int usageCount = 0;
    QDateTime lastUsedAt;
    QDateTime createdAt;
    QString vendorCode;
    QString vendorName;
};

struct ModelConfig {
    int id = -1;
    int apiKeyId = -1;
    QString displayName;
    QString modelName;
    QJsonObject parameters;
    bool isEnabled = true;
    bool isFavorite = false;
    int sortOrder = 0;
    int usageCount = 0;
    qint64 totalTokens = 0;
    QDateTime lastUsedAt;
    ApiKey keyInfo;
    ModelVendor vendorInfo;
};

// QML 可用的 Vendor 包装类
class VendorObject : public QObject {
    Q_OBJECT
    Q_PROPERTY(int id READ id CONSTANT)
    Q_PROPERTY(QString code READ code CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString website READ website CONSTANT)
    Q_PROPERTY(QString apiDocsUrl READ apiDocsUrl CONSTANT)
    Q_PROPERTY(QString defaultBaseUrl READ defaultBaseUrl CONSTANT)
    Q_PROPERTY(bool isOfficial READ isOfficial CONSTANT)

public:
    explicit VendorObject(const ModelVendor &vendor, QObject *parent = nullptr);

    int id() const { return m_vendor.id; }
    QString code() const { return m_vendor.code; }
    QString name() const { return m_vendor.name; }
    QString website() const { return m_vendor.website; }
    QString apiDocsUrl() const { return m_vendor.apiDocsUrl; }
    QString defaultBaseUrl() const { return m_vendor.defaultBaseUrl; }
    bool isOfficial() const { return m_vendor.isOfficial; }

private:
    ModelVendor m_vendor;
};

// QML 可用的 ApiKey 包装类
class ApiKeyObject : public QObject {
    Q_OBJECT
    Q_PROPERTY(int id READ id CONSTANT)
    Q_PROPERTY(int vendorId READ vendorId CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString keyMask READ keyMask CONSTANT)
    Q_PROPERTY(bool isEnabled READ isEnabled WRITE setIsEnabled NOTIFY isEnabledChanged)
    Q_PROPERTY(bool isDefault READ isDefault WRITE setIsDefault NOTIFY isDefaultChanged)
    Q_PROPERTY(int rateLimitPerMinute READ rateLimitPerMinute CONSTANT)
    Q_PROPERTY(double monthlyBudgetUsd READ monthlyBudgetUsd CONSTANT)
    Q_PROPERTY(int usageCount READ usageCount CONSTANT)
    Q_PROPERTY(QString vendorCode READ vendorCode CONSTANT)
    Q_PROPERTY(QString vendorName READ vendorName CONSTANT)

public:
    explicit ApiKeyObject(const ApiKey &key, QObject *parent = nullptr);

    int id() const { return m_key.id; }
    int vendorId() const { return m_key.vendorId; }
    QString name() const { return m_key.name; }
    QString keyMask() const { return m_key.keyMask; }
    bool isEnabled() const { return m_key.isEnabled; }
    bool isDefault() const { return m_key.isDefault; }
    int rateLimitPerMinute() const { return m_key.rateLimitPerMinute; }
    double monthlyBudgetUsd() const { return m_key.monthlyBudgetUsd; }
    int usageCount() const { return m_key.usageCount; }
    QString vendorCode() const { return m_key.vendorCode; }
    QString vendorName() const { return m_key.vendorName; }

    void setIsEnabled(bool enabled);
    void setIsDefault(bool isDefault);

signals:
    void isEnabledChanged();
    void isDefaultChanged();

private:
    ApiKey m_key;
};

// QML 可用的 ModelConfig 包装类
class ModelConfigObject : public QObject {
    Q_OBJECT
    Q_PROPERTY(int id READ id CONSTANT)
    Q_PROPERTY(int apiKeyId READ apiKeyId CONSTANT)
    Q_PROPERTY(QString displayName READ displayName CONSTANT)
    Q_PROPERTY(QString modelName READ modelName CONSTANT)
    Q_PROPERTY(QJsonObject parameters READ parameters CONSTANT)
    Q_PROPERTY(bool isEnabled READ isEnabled WRITE setIsEnabled NOTIFY isEnabledChanged)
    Q_PROPERTY(bool isFavorite READ isFavorite WRITE setIsFavorite NOTIFY isFavoriteChanged)
    Q_PROPERTY(int sortOrder READ sortOrder CONSTANT)
    Q_PROPERTY(QString keyMask READ keyMask CONSTANT)
    Q_PROPERTY(QString vendorCode READ vendorCode CONSTANT)
    Q_PROPERTY(QString vendorName READ vendorName CONSTANT)

public:
    explicit ModelConfigObject(const ModelConfig &config, QObject *parent = nullptr);

    int id() const { return m_config.id; }
    int apiKeyId() const { return m_config.apiKeyId; }
    QString displayName() const { return m_config.displayName; }
    QString modelName() const { return m_config.modelName; }
    QJsonObject parameters() const { return m_config.parameters; }
    bool isEnabled() const { return m_config.isEnabled; }
    bool isFavorite() const { return m_config.isFavorite; }
    int sortOrder() const { return m_config.sortOrder; }
    QString keyMask() const { return m_config.keyInfo.keyMask; }
    QString vendorCode() const { return m_config.vendorInfo.code; }
    QString vendorName() const { return m_config.vendorInfo.name; }

    void setIsEnabled(bool enabled);
    void setIsFavorite(bool favorite);

signals:
    void isEnabledChanged();
    void isFavoriteChanged();

private:
    ModelConfig m_config;
};

class ModelConfigManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool initialized READ isInitialized NOTIFY initializedChanged)

public:
    explicit ModelConfigManager(QObject *parent = nullptr);
    ~ModelConfigManager();

    // QML 单例工厂方法
    static ModelConfigManager* create(QQmlEngine *engine, QJSEngine *scriptEngine);
    static void registerQml();

    Q_INVOKABLE bool initialize(const QString &dbPath, const QString &encryptionKey = QString());

    // QML 可用的方法
    Q_INVOKABLE QList<QObject*> listVendorsQml();
    Q_INVOKABLE QList<QObject*> listApiKeysQml(int vendorId = -1, bool onlyEnabled = true);
    Q_INVOKABLE QList<QObject*> listConfigsQml(int vendorId = -1, const QString &search = QString(), bool onlyEnabled = true);

    Q_INVOKABLE bool addApiKeyQml(int vendorId, const QString &name, const QString &plainKey,
                                  const QJsonObject &options = QJsonObject());
    Q_INVOKABLE bool deleteApiKeyQml(int id);
    Q_INVOKABLE bool updateApiKeySecretQml(int id, const QString &newPlainKey);

    Q_INVOKABLE bool addConfigQml(int apiKeyId, const QString &displayName, const QString &modelName,
                                  const QJsonObject &parameters = QJsonObject());
    Q_INVOKABLE bool deleteConfigQml(int id);
    Q_INVOKABLE bool toggleConfigFavoriteQml(int id, bool isFavorite);

    Q_INVOKABLE QString decryptApiKeyQml(int id);
    Q_INVOKABLE QJsonObject getRuntimeConfigQml(int configId);

    bool isInitialized() const { return m_initialized; }
    QList<ModelVendor> listVendors();
    std::optional<ModelVendor> getVendor(const QString &code);

    bool addApiKey(const ApiKey &key, const QString &plainKey);
    bool updateApiKey(int id, const ApiKey &key);
    bool deleteApiKey(int id);
    bool updateApiKeySecret(int id, const QString &newPlainKey);
    QList<ApiKey> listApiKeys(int vendorId = -1, bool onlyEnabled = false);
    std::optional<ApiKey> getApiKey(int id);
    QString decryptApiKey(int id);

    bool addConfig(const ModelConfig &config);
    bool updateConfig(const ModelConfig &config);
    bool deleteConfig(int id);
    QList<ModelConfig> listConfigs(
        int vendorId = -1,
        const QString &search = QString(),
        bool onlyEnabled = true,
        bool favoritesFirst = true
        );
    std::optional<ModelConfig> getConfig(int id);
    std::optional<ModelConfig> getDefaultConfig(const QString &vendorCode);
    struct RuntimeConfig {
        QString apiKey;
        QString baseUrl;
        QString modelName;
        QJsonObject parameters;
        int configId;
    };
    std::optional<RuntimeConfig> getRuntimeConfig(int configId);

    bool recordUsage(int configId, int tokensUsed, int latencyMs = 0);

signals:
    void initializedChanged();
    void vendorsChanged();
    void apiKeysChanged();
    void configsChanged();
    void apiKeyAdded(int id);
    void configAdded(int id);
    void error(const QString &message);

    // 转发内部信号到 QML
    void apiKeyChanged(int id);
    void configChanged(int id);
    void configAdded(const ModelConfig &config);

private:
    bool createTables();
    bool initDefaultVendors();

    static QString modelVendorsSql;
    static QString apiKeysSql;
    static QString modelConfigsSql;
    static QString modelConfigViewSql;

    QByteArray encrypt(const QString &plaintext);
    QString decrypt(const QByteArray &ciphertext);
    static QString maskKey(const QString &key);

    QSqlDatabase m_db;
    QString m_connectionName;
    QByteArray m_encryptionKey;
    QMutex m_mutex;
    bool m_initialized = false;
};

#endif
