// ModelConfigManager.cpp
#include "ModelConfigManager.h"
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QJsonDocument>
#include <QCryptographicHash>
#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QList>
// === VendorObject 实现 ===
VendorObject::VendorObject(const ModelVendor &vendor, QObject *parent)
    : QObject(parent), m_vendor(vendor) {}

// === ApiKeyObject 实现 ===
ApiKeyObject::ApiKeyObject(const ApiKey &key, QObject *parent)
    : QObject(parent), m_key(key) {}

void ApiKeyObject::setIsEnabled(bool enabled) {
    if (m_key.isEnabled != enabled) {
        m_key.isEnabled = enabled;
        emit isEnabledChanged();
    }
}

void ApiKeyObject::setIsDefault(bool isDefault) {
    if (m_key.isDefault != isDefault) {
        m_key.isDefault = isDefault;
        emit isDefaultChanged();
    }
}

// === ModelConfigObject 实现 ===
ModelConfigObject::ModelConfigObject(const ModelConfig &config, QObject *parent)
    : QObject(parent), m_config(config) {}

void ModelConfigObject::setIsEnabled(bool enabled) {
    if (m_config.isEnabled != enabled) {
        m_config.isEnabled = enabled;
        emit isEnabledChanged();
    }
}

void ModelConfigObject::setIsFavorite(bool favorite) {
    if (m_config.isFavorite != favorite) {
        m_config.isFavorite = favorite;
        emit isFavoriteChanged();
    }
}

// === ModelConfigManager 实现 ===

// 静态单例指针
static ModelConfigManager *s_instance = nullptr;

// QML 单例工厂
ModelConfigManager* ModelConfigManager::create(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    if (!s_instance) {
        s_instance = new ModelConfigManager();
    }
    return s_instance;
}

// 注册到 QML
void ModelConfigManager::registerQml()
{
    qmlRegisterSingletonType<ModelConfigManager>(
        "ModelConfig", 1, 0, "ConfigManager",
        &ModelConfigManager::create
        );

    // 注册对象类型（QML 可创建，但通常由 C++ 创建返回）
    qmlRegisterUncreatableType<VendorObject>("ModelConfig", 1, 0, "Vendor", "Created by ConfigManager");
    qmlRegisterUncreatableType<ApiKeyObject>("ModelConfig", 1, 0, "ApiKey", "Created by ConfigManager");
    qmlRegisterUncreatableType<ModelConfigObject>("ModelConfig", 1, 0, "ModelConfig", "Created by ConfigManager");
}


// 静态 SQL 定义
QString ModelConfigManager::modelVendorsSql = R"(
    CREATE TABLE IF NOT EXISTS model_vendors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        website TEXT,
        api_docs_url TEXT,
        default_base_url TEXT,
        is_official INTEGER DEFAULT 1,
        created_at INTEGER
    )
)";

QString ModelConfigManager::apiKeysSql = R"(
    CREATE TABLE IF NOT EXISTS api_keys (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vendor_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        key_encrypted BLOB NOT NULL,
        key_mask TEXT,
        is_enabled INTEGER DEFAULT 1,
        is_default INTEGER DEFAULT 0,
        rate_limit_per_minute INTEGER,
        monthly_budget_usd REAL,
        usage_count INTEGER DEFAULT 0,
        last_used_at INTEGER,
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (vendor_id) REFERENCES model_vendors(id) ON DELETE CASCADE,
        UNIQUE(vendor_id, name)
    )
)";

QString ModelConfigManager::modelConfigsSql = R"(
    CREATE TABLE IF NOT EXISTS model_configs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        api_key_id INTEGER NOT NULL,
        model_name TEXT NOT NULL,
        display_name TEXT NOT NULL,
        parameters TEXT,
        is_enabled INTEGER DEFAULT 1,
        is_favorite INTEGER DEFAULT 0,
        sort_order INTEGER DEFAULT 0,
        usage_count INTEGER DEFAULT 0,
        total_tokens INTEGER DEFAULT 0,
        last_used_at INTEGER,
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (api_key_id) REFERENCES api_keys(id) ON DELETE CASCADE
    )
)";

QString ModelConfigManager::modelConfigViewSql = R"(
    CREATE VIEW IF NOT EXISTS v_model_configs AS
    SELECT
        mc.id,
        mc.display_name,
        mc.model_name,
        mc.parameters,
        mc.is_enabled,
        mc.is_favorite,
        mc.sort_order,
        mc.usage_count,
        mc.total_tokens,
        mc.last_used_at,
        mc.created_at,
        mc.updated_at,
        ak.id as key_id,
        ak.name as key_name,
        ak.key_mask,
        ak.is_default as key_is_default,
        ak.rate_limit_per_minute,
        ak.monthly_budget_usd,
        ak.vendor_id,
        v.code as vendor_code,
        v.name as vendor_name,
        v.default_base_url
    FROM model_configs mc
    JOIN api_keys ak ON mc.api_key_id = ak.id
    JOIN model_vendors v ON ak.vendor_id = v.id
    WHERE ak.is_enabled = 1
)";

ModelConfigManager::ModelConfigManager(QObject *parent)
    : QObject(parent)
{
    m_connectionName = QString("modelcfg_%1").arg(quintptr(this));
}

ModelConfigManager::~ModelConfigManager()
{
    if (QSqlDatabase::contains(m_connectionName)) {
        QSqlDatabase db = QSqlDatabase::database(m_connectionName);
        if (db.isOpen()) {
            db.close();
        }
    }
}

bool ModelConfigManager::initialize(const QString &dbPath, const QString &encryptionKey)
{
    QMutexLocker locker(&m_mutex);

    // 确保目录存在
    QDir dir(QFileInfo(dbPath).path());
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    m_db = QSqlDatabase::addDatabase("QSQLITE", m_connectionName);
    m_db.setDatabaseName(dbPath);

    // Qt 6 优化设置
    m_db.setConnectOptions(
        "QSQLITE_BUSY_TIMEOUT=5000;"
        );

    if (!m_db.open()) {
        qWarning() << "Failed to open database:" << m_db.lastError().text();
        return false;
    }

    // 启用外键
    QSqlQuery("PRAGMA foreign_keys = ON", m_db);
    QSqlQuery("PRAGMA journal_mode = WAL", m_db);

    // 设置加密密钥
    if (!encryptionKey.isEmpty()) {
        m_encryptionKey = QCryptographicHash::hash(
            encryptionKey.toUtf8(),
            QCryptographicHash::Sha256
            );
    }

    if (!createTables()) return false;
    if (!initDefaultVendors()) return false;

    return true;
}

bool ModelConfigManager::createTables()
{
    QStringList ddls = {
        modelVendorsSql,
        apiKeysSql,
        modelConfigsSql,
        modelConfigViewSql,
        "CREATE INDEX IF NOT EXISTS idx_api_keys_vendor ON api_keys(vendor_id)",
        "CREATE INDEX IF NOT EXISTS idx_api_keys_enabled ON api_keys(is_enabled)",
        "CREATE INDEX IF NOT EXISTS idx_model_configs_key ON model_configs(api_key_id)",
        "CREATE INDEX IF NOT EXISTS idx_model_configs_enabled ON model_configs(is_enabled)"
    };

    for (const QString &sql : ddls) {
        QSqlQuery query(m_db);
        if (!query.exec(sql)) {
            qWarning() << "DDL failed:" << query.lastError().text() << "\nSQL:" << sql;
            return false;
        }
    }
    return true;
}

bool ModelConfigManager::initDefaultVendors()
{
    QList<ModelVendor> defaults;
    defaults << ModelVendor{-1, "openai", "OpenAI", "https://openai.com", "https://platform.openai.com/docs", "https://api.openai.com/v1", true}
             << ModelVendor{-1, "anthropic", "Anthropic", "https://anthropic.com", "https://docs.anthropic.com", "https://api.anthropic.com/v1", true}
             << ModelVendor{-1, "google", "Google AI", "https://ai.google.dev", "https://ai.google.dev/docs", "https://generativelanguage.googleapis.com/v1", true}
             << ModelVendor{-1, "alibaba", "阿里云百炼", "https://bailian.aliyun.com", "https://help.aliyun.com/document_detail/2587497.html", "https://dashscope.aliyuncs.com/api/v1", true}
             << ModelVendor{-1, "deepseek", "DeepSeek", "https://deepseek.com", "https://platform.deepseek.com/api-docs", "https://api.deepseek.com/v1", true}
             << ModelVendor{-1, "moonshot", "Moonshot AI", "https://moonshot.cn", "https://platform.moonshot.cn/docs", "https://api.moonshot.cn/v1", true}
             << ModelVendor{-1, "baidu", "百度千帆", "https://qianfan.baidu.com", "https://cloud.baidu.com/doc/WENXINWORKSHOP/index.html", "https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop", true}
             << ModelVendor{-1, "zhipu", "智谱 AI", "https://zhipuai.cn", "https://open.bigmodel.cn/dev/api", "https://open.bigmodel.cn/api/paas/v4", true}
             << ModelVendor{-1, "openrouter", "OpenRouter", "https://openrouter.ai", "https://openrouter.ai/docs", "https://openrouter.ai/api/v1", true}
             << ModelVendor{-1, "ollama", "Ollama", "https://ollama.com", "https://github.com/ollama/ollama/blob/main/docs/api.md", "http://localhost:11434", true}
             << ModelVendor{-1, "lmstudio", "LM Studio", "https://lmstudio.ai", "https://lmstudio.ai/docs", "http://localhost:1234", true};

    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT OR IGNORE INTO model_vendors
        (code, name, website, api_docs_url, default_base_url, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
    )");

    qint64 now = QDateTime::currentMSecsSinceEpoch();
    for (const auto &v : std::as_const(defaults)) {
        query.addBindValue(v.code);
        query.addBindValue(v.name);
        query.addBindValue(v.website);
        query.addBindValue(v.apiDocsUrl);
        query.addBindValue(v.defaultBaseUrl);
        query.addBindValue(now);
        query.exec();
        query.finish();
    }

    return true;
}

// === 加密/解密 ===
QByteArray ModelConfigManager::encrypt(const QString &plaintext)
{
    if (m_encryptionKey.isEmpty()) {
        // 无加密密钥，简单 Base64（不安全，仅演示）
        return plaintext.toUtf8().toBase64();
    }

    // 简单 XOR 加密（生产环境请替换为 AES-256-GCM）
    QByteArray data = plaintext.toUtf8();
    for (int i = 0; i < data.size(); ++i) {
        data[i] = data[i] ^ m_encryptionKey[i % m_encryptionKey.size()];
    }
    return data.toBase64();
}

QString ModelConfigManager::decrypt(const QByteArray &ciphertext)
{
    if (m_encryptionKey.isEmpty()) {
        return QByteArray::fromBase64(ciphertext);
    }

    QByteArray data = QByteArray::fromBase64(ciphertext);
    for (int i = 0; i < data.size(); ++i) {
        data[i] = data[i] ^ m_encryptionKey[i % m_encryptionKey.size()];
    }
    return QString::fromUtf8(data);
}

QString ModelConfigManager::maskKey(const QString &key)
{
    if (key.isEmpty()) {
        return QString();
    }

    const int visibleHead = 4;
    const int visibleTail = 4;

    int len = key.length();

    // 太短：全掩码
    if (len <= visibleHead + visibleTail) {
        return QString(len, '*');
    }

    // 识别并保留前缀
    QString prefix;
    QString body = key;

    static const QStringList prefixes = {"sk-", "pk-", "sk_", "pk_", "AK", "SK", "Bearer "};
    for (const QString &p : prefixes) {
        if (key.startsWith(p)) {
            prefix = p;
            body = key.mid(p.length());
            break;
        }
    }

    // 对 body 脱敏
    int bodyLen = body.length();
    if (bodyLen <= visibleHead + visibleTail) {
        return prefix + body.left(2) + "..." + body.right(2);
    }

    return prefix + body.left(visibleHead) + "..." + body.right(visibleTail);
}

// === 厂商管理 ===
QList<ModelVendor> ModelConfigManager::listVendors()
{
    QMutexLocker locker(&m_mutex);
    QList<ModelVendor> list;

    // 检查数据库状态
    if (!m_db.isValid() || !m_db.isOpen()) {
        qWarning() << "Database not ready in listVendors";
        return list;
    }

    QSqlQuery query(m_db);
    query.prepare("SELECT * FROM model_vendors ORDER BY name");

    // 关键修复：检查执行结果
    if (!query.exec()) {
        qWarning() << "listVendors query failed:" << query.lastError().text();
        return list;
    }

    // 调试：检查是否有结果
    if (!query.next()) {
        qDebug() << "listVendors: table empty or not found";
        return list;
    }

    // 使用 do-while 因为已经 next() 了一次
    do {
        ModelVendor v;
        v.id = query.value("id").toInt();
        v.code = query.value("code").toString();
        v.name = query.value("name").toString();
        v.website = query.value("website").toString();
        v.apiDocsUrl = query.value("api_docs_url").toString();
        v.defaultBaseUrl = query.value("default_base_url").toString();
        v.isOfficial = query.value("is_official").toBool();
        list.append(v);
    } while (query.next());

    qDebug() << "listVendors: loaded" << list.size() << "vendors";
    return list;
}

std::optional<ModelVendor> ModelConfigManager::getVendor(const QString &code)
{
    QMutexLocker locker(&m_mutex);

    QSqlQuery query(m_db);
    query.prepare("SELECT * FROM model_vendors WHERE code=?");
    query.addBindValue(code);

    if (!query.exec() || !query.next()) {
        return std::nullopt;
    }

    ModelVendor v;
    v.id = query.value("id").toInt();
    v.code = query.value("code").toString();
    v.name = query.value("name").toString();
    v.website = query.value("website").toString();
    v.apiDocsUrl = query.value("api_docs_url").toString();
    v.defaultBaseUrl = query.value("default_base_url").toString();
    v.isOfficial = query.value("is_official").toBool();

    return v;
}

// === API Key 管理 ===
bool ModelConfigManager::addApiKey(const ApiKey &key, const QString &plainKey)
{
    QMutexLocker locker(&m_mutex);

    if (plainKey.isEmpty()) {
        qWarning() << "API Key cannot be empty";
        return false;
    }

    // 检查同厂商同名
    QSqlQuery check(m_db);
    check.prepare("SELECT 1 FROM api_keys WHERE vendor_id=? AND name=?");
    check.addBindValue(key.vendorId);
    check.addBindValue(key.name);
    if (check.exec() && check.next()) {
        qWarning() << "Key name already exists for this vendor";
        return false;
    }

    // 如果是该厂商第一个 Key，设为默认
    QSqlQuery count(m_db);
    count.prepare("SELECT COUNT(*) FROM api_keys WHERE vendor_id=? AND is_enabled=1");
    count.addBindValue(key.vendorId);
    bool isFirst = (!count.exec() || !count.next() || count.value(0).toInt() == 0);

    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO api_keys
        (vendor_id, name, key_encrypted, key_mask, is_enabled, is_default,
         rate_limit_per_minute, monthly_budget_usd, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    )");

    qint64 now = QDateTime::currentMSecsSinceEpoch();

    query.addBindValue(key.vendorId);
    query.addBindValue(key.name);
    query.addBindValue(encrypt(plainKey));
    query.addBindValue(maskKey(plainKey));
    query.addBindValue(key.isEnabled ? 1 : 0);
    query.addBindValue((key.isDefault || isFirst) ? 1 : 0);
    query.addBindValue(key.rateLimitPerMinute);
    query.addBindValue(key.monthlyBudgetUsd);
    query.addBindValue(now);
    query.addBindValue(now);

    if (!query.exec()) {
        qWarning() << "Add API key failed:" << query.lastError().text();
        return false;
    }

    int newId = query.lastInsertId().toInt();

    // 处理默认 Key 切换
    if (key.isDefault || isFirst) {
        QSqlQuery update(m_db);
        update.prepare("UPDATE api_keys SET is_default=0 WHERE vendor_id=? AND id!=?");
        update.addBindValue(key.vendorId);
        update.addBindValue(newId);
        update.exec();
    }

    emit apiKeyChanged(newId);
    return true;
}

bool ModelConfigManager::updateApiKey(int id, const ApiKey &key)
{
    QMutexLocker locker(&m_mutex);

    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE api_keys SET
            name = ?,
            is_enabled = ?,
            rate_limit_per_minute = ?,
            monthly_budget_usd = ?,
            updated_at = ?
        WHERE id = ?
    )");

    query.addBindValue(key.name);
    query.addBindValue(key.isEnabled ? 1 : 0);
    query.addBindValue(key.rateLimitPerMinute);
    query.addBindValue(key.monthlyBudgetUsd);
    query.addBindValue(QDateTime::currentMSecsSinceEpoch());
    query.addBindValue(id);

    if (!query.exec()) {
        qWarning() << "Update API key failed:" << query.lastError().text();
        return false;
    }

    emit apiKeyChanged(id);
    return true;
}

bool ModelConfigManager::deleteApiKey(int id)
{
    QMutexLocker locker(&m_mutex);

    QSqlQuery query(m_db);
    query.prepare("DELETE FROM api_keys WHERE id=?");
    query.addBindValue(id);

    if (!query.exec()) {
        qWarning() << "Delete API key failed:" << query.lastError().text();
        return false;
    }

    emit apiKeyChanged(id);
    return true;
}

bool ModelConfigManager::updateApiKeySecret(int id, const QString &newPlainKey)
{
    QMutexLocker locker(&m_mutex);

    if (newPlainKey.isEmpty()) {
        qWarning() << "New API Key cannot be empty";
        return false;
    }

    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE api_keys SET
            key_encrypted = ?,
            key_mask = ?,
            updated_at = ?
        WHERE id = ?
    )");

    query.addBindValue(encrypt(newPlainKey));
    query.addBindValue(maskKey(newPlainKey));
    query.addBindValue(QDateTime::currentMSecsSinceEpoch());
    query.addBindValue(id);

    if (!query.exec()) {
        qWarning() << "Update API key secret failed:" << query.lastError().text();
        return false;
    }

    emit apiKeyChanged(id);
    return true;
}

QList<ApiKey> ModelConfigManager::listApiKeys(int vendorId, bool onlyEnabled)
{
    QMutexLocker locker(&m_mutex);
    QList<ApiKey> list;

    QString sql = R"(
        SELECT ak.*, v.code as vendor_code, v.name as vendor_name
        FROM api_keys ak
        JOIN model_vendors v ON ak.vendor_id = v.id
        WHERE 1=1
    )";
    if (vendorId > 0) sql += " AND ak.vendor_id=?";
    if (onlyEnabled) sql += " AND ak.is_enabled=1";
    sql += " ORDER BY ak.is_default DESC, ak.created_at DESC";

    QSqlQuery query(m_db);
    query.prepare(sql);
    if (vendorId > 0) query.addBindValue(vendorId);

    if (!query.exec()) {
        qWarning() << "List API keys failed:" << query.lastError().text();
        return list;
    }

    while (query.next()) {
        ApiKey k;
        k.id = query.value("id").toInt();
        k.vendorId = query.value("vendor_id").toInt();
        k.name = query.value("name").toString();
        k.keyMask = query.value("key_mask").toString();
        k.isEnabled = query.value("is_enabled").toBool();
        k.isDefault = query.value("is_default").toBool();
        k.rateLimitPerMinute = query.value("rate_limit_per_minute").toInt();
        k.monthlyBudgetUsd = query.value("monthly_budget_usd").toDouble();
        k.usageCount = query.value("usage_count").toInt();
        k.vendorCode = query.value("vendor_code").toString();
        k.vendorName = query.value("vendor_name").toString();

        qint64 lastUsed = query.value("last_used_at").toLongLong();
        if (lastUsed > 0) k.lastUsedAt = QDateTime::fromMSecsSinceEpoch(lastUsed);
        k.createdAt = QDateTime::fromMSecsSinceEpoch(query.value("created_at").toLongLong());

        list.append(k);
    }

    return list;
}

std::optional<ApiKey> ModelConfigManager::getApiKey(int id)
{
    QMutexLocker locker(&m_mutex);

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT ak.*, v.code as vendor_code, v.name as vendor_name
        FROM api_keys ak
        JOIN model_vendors v ON ak.vendor_id = v.id
        WHERE ak.id=?
    )");
    query.addBindValue(id);

    if (!query.exec() || !query.next()) {
        return std::nullopt;
    }

    ApiKey k;
    k.id = query.value("id").toInt();
    k.vendorId = query.value("vendor_id").toInt();
    k.name = query.value("name").toString();
    k.keyMask = query.value("key_mask").toString();
    k.isEnabled = query.value("is_enabled").toBool();
    k.isDefault = query.value("is_default").toBool();
    k.rateLimitPerMinute = query.value("rate_limit_per_minute").toInt();
    k.monthlyBudgetUsd = query.value("monthly_budget_usd").toDouble();
    k.usageCount = query.value("usage_count").toInt();
    k.vendorCode = query.value("vendor_code").toString();
    k.vendorName = query.value("vendor_name").toString();

    qint64 lastUsed = query.value("last_used_at").toLongLong();
    if (lastUsed > 0) k.lastUsedAt = QDateTime::fromMSecsSinceEpoch(lastUsed);
    k.createdAt = QDateTime::fromMSecsSinceEpoch(query.value("created_at").toLongLong());

    return k;
}

QString ModelConfigManager::decryptApiKey(int id)
{
    QMutexLocker locker(&m_mutex);

    QSqlQuery query(m_db);
    query.prepare("SELECT key_encrypted FROM api_keys WHERE id=? AND is_enabled=1");
    query.addBindValue(id);

    if (!query.exec() || !query.next()) {
        return QString();
    }

    return decrypt(query.value(0).toByteArray());
}

// === 模型配置管理 ===
bool ModelConfigManager::addConfig(const ModelConfig &config)
{
    QMutexLocker locker(&m_mutex);

    // 验证 api_key_id 有效
    QSqlQuery keyCheck(m_db);
    keyCheck.prepare("SELECT vendor_id FROM api_keys WHERE id=? AND is_enabled=1");
    keyCheck.addBindValue(config.apiKeyId);
    if (!keyCheck.exec() || !keyCheck.next()) {
        qWarning() << "Invalid or disabled API Key";
        return false;
    }

    // 检查同名配置
    QSqlQuery check(m_db);
    check.prepare("SELECT 1 FROM model_configs WHERE api_key_id=? AND display_name=?");
    check.addBindValue(config.apiKeyId);
    check.addBindValue(config.displayName);
    if (check.exec() && check.next()) {
        qWarning() << "Config name already exists for this key";
        return false;
    }

    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO model_configs
        (api_key_id, model_name, display_name, parameters,
         is_enabled, is_favorite, sort_order, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    )");

    qint64 now = QDateTime::currentMSecsSinceEpoch();

    query.addBindValue(config.apiKeyId);
    query.addBindValue(config.modelName);
    query.addBindValue(config.displayName);
    query.addBindValue(QString::fromUtf8(QJsonDocument(config.parameters).toJson()));
    query.addBindValue(config.isEnabled ? 1 : 0);
    query.addBindValue(config.isFavorite ? 1 : 0);
    query.addBindValue(config.sortOrder);
    query.addBindValue(now);
    query.addBindValue(now);

    if (!query.exec()) {
        qWarning() << "Add config failed:" << query.lastError().text();
        return false;
    }

    int newId = query.lastInsertId().toInt();

    // 获取完整信息返回
    if (auto full = getConfig(newId)) {
        emit configAdded(*full);
    }

    return true;
}

bool ModelConfigManager::updateConfig(const ModelConfig &config)
{
    QMutexLocker locker(&m_mutex);

    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE model_configs SET
            api_key_id = ?,
            model_name = ?,
            display_name = ?,
            parameters = ?,
            is_enabled = ?,
            is_favorite = ?,
            sort_order = ?,
            updated_at = ?
        WHERE id = ?
    )");

    query.addBindValue(config.apiKeyId);
    query.addBindValue(config.modelName);
    query.addBindValue(config.displayName);
    query.addBindValue(QString::fromUtf8(QJsonDocument(config.parameters).toJson()));
    query.addBindValue(config.isEnabled ? 1 : 0);
    query.addBindValue(config.isFavorite ? 1 : 0);
    query.addBindValue(config.sortOrder);
    query.addBindValue(QDateTime::currentMSecsSinceEpoch());
    query.addBindValue(config.id);

    if (!query.exec()) {
        qWarning() << "Update config failed:" << query.lastError().text();
        return false;
    }

    emit configChanged(config.id);
    return true;
}

bool ModelConfigManager::deleteConfig(int id)
{
    QMutexLocker locker(&m_mutex);

    QSqlQuery query(m_db);
    query.prepare("DELETE FROM model_configs WHERE id=?");
    query.addBindValue(id);

    if (!query.exec()) {
        qWarning() << "Delete config failed:" << query.lastError().text();
        return false;
    }

    emit configChanged(id);
    return true;
}

QList<ModelConfig> ModelConfigManager::listConfigs(
    int vendorId,
    const QString &search,
    bool onlyEnabled,
    bool favoritesFirst
    )
{
    QMutexLocker locker(&m_mutex);
    QList<ModelConfig> list;

    QString sql = R"(
        SELECT
            mc.*,
            ak.name as key_name, ak.key_mask, ak.is_default as key_is_default,
            ak.rate_limit_per_minute, ak.monthly_budget_usd,
            ak.vendor_id, v.code as vendor_code, v.name as vendor_name,
            v.default_base_url
        FROM model_configs mc
        JOIN api_keys ak ON mc.api_key_id = ak.id
        JOIN model_vendors v ON ak.vendor_id = v.id
        WHERE 1=1
    )";

    if (vendorId > 0) sql += " AND ak.vendor_id=?";
    if (!search.isEmpty()) sql += " AND mc.display_name LIKE ?";
    if (onlyEnabled) sql += " AND mc.is_enabled=1 AND ak.is_enabled=1";

    sql += favoritesFirst ?
               " ORDER BY mc.is_favorite DESC, mc.sort_order ASC, mc.created_at DESC" :
               " ORDER BY mc.sort_order ASC, mc.created_at DESC";

    QSqlQuery query(m_db);
    query.prepare(sql);

    int paramIdx = 0;
    if (vendorId > 0) query.bindValue(paramIdx++, vendorId);
    if (!search.isEmpty()) query.bindValue(paramIdx++, "%" + search + "%");

    if (!query.exec()) {
        qWarning() << "List configs failed:" << query.lastError().text();
        return list;
    }

    while (query.next()) {
        ModelConfig cfg;
        cfg.id = query.value("id").toInt();
        cfg.apiKeyId = query.value("api_key_id").toInt();
        cfg.displayName = query.value("display_name").toString();
        cfg.modelName = query.value("model_name").toString();
        cfg.parameters = QJsonDocument::fromJson(
                             query.value("parameters").toByteArray()
                             ).object();
        cfg.isEnabled = query.value("is_enabled").toBool();
        cfg.isFavorite = query.value("is_favorite").toBool();
        cfg.sortOrder = query.value("sort_order").toInt();
        cfg.usageCount = query.value("usage_count").toInt();
        cfg.totalTokens = query.value("total_tokens").toLongLong();

        // Key 信息
        cfg.keyInfo.id = cfg.apiKeyId;
        cfg.keyInfo.name = query.value("key_name").toString();
        cfg.keyInfo.keyMask = query.value("key_mask").toString();
        cfg.keyInfo.isDefault = query.value("key_is_default").toBool();
        cfg.keyInfo.rateLimitPerMinute = query.value("rate_limit_per_minute").toInt();
        cfg.keyInfo.monthlyBudgetUsd = query.value("monthly_budget_usd").toDouble();
        cfg.keyInfo.vendorId = query.value("vendor_id").toInt();

        // 厂商信息
        cfg.vendorInfo.id = cfg.keyInfo.vendorId;
        cfg.vendorInfo.code = query.value("vendor_code").toString();
        cfg.vendorInfo.name = query.value("vendor_name").toString();
        cfg.vendorInfo.defaultBaseUrl = query.value("default_base_url").toString();

        qint64 lastUsed = query.value("last_used_at").toLongLong();
        if (lastUsed > 0) cfg.lastUsedAt = QDateTime::fromMSecsSinceEpoch(lastUsed);

        list.append(cfg);
    }

    return list;
}

std::optional<ModelConfig> ModelConfigManager::getConfig(int id)
{
    QMutexLocker locker(&m_mutex);

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT
            mc.*,
            ak.name as key_name, ak.key_mask, ak.is_default as key_is_default,
            ak.rate_limit_per_minute, ak.monthly_budget_usd,
            ak.vendor_id, v.code as vendor_code, v.name as vendor_name,
            v.default_base_url
        FROM model_configs mc
        JOIN api_keys ak ON mc.api_key_id = ak.id
        JOIN model_vendors v ON ak.vendor_id = v.id
        WHERE mc.id=?
    )");
    query.addBindValue(id);

    if (!query.exec() || !query.next()) {
        return std::nullopt;
    }

    ModelConfig cfg;
    cfg.id = query.value("id").toInt();
    cfg.apiKeyId = query.value("api_key_id").toInt();
    cfg.displayName = query.value("display_name").toString();
    cfg.modelName = query.value("model_name").toString();
    cfg.parameters = QJsonDocument::fromJson(
                         query.value("parameters").toByteArray()
                         ).object();
    cfg.isEnabled = query.value("is_enabled").toBool();
    cfg.isFavorite = query.value("is_favorite").toBool();
    cfg.sortOrder = query.value("sort_order").toInt();
    cfg.usageCount = query.value("usage_count").toInt();
    cfg.totalTokens = query.value("total_tokens").toLongLong();

    cfg.keyInfo.id = cfg.apiKeyId;
    cfg.keyInfo.name = query.value("key_name").toString();
    cfg.keyInfo.keyMask = query.value("key_mask").toString();
    cfg.keyInfo.isDefault = query.value("key_is_default").toBool();
    cfg.keyInfo.rateLimitPerMinute = query.value("rate_limit_per_minute").toInt();
    cfg.keyInfo.monthlyBudgetUsd = query.value("monthly_budget_usd").toDouble();
    cfg.keyInfo.vendorId = query.value("vendor_id").toInt();

    cfg.vendorInfo.id = cfg.keyInfo.vendorId;
    cfg.vendorInfo.code = query.value("vendor_code").toString();
    cfg.vendorInfo.name = query.value("vendor_name").toString();
    cfg.vendorInfo.defaultBaseUrl = query.value("default_base_url").toString();

    qint64 lastUsed = query.value("last_used_at").toLongLong();
    if (lastUsed > 0) cfg.lastUsedAt = QDateTime::fromMSecsSinceEpoch(lastUsed);

    return cfg;
}

std::optional<ModelConfig> ModelConfigManager::getDefaultConfig(const QString &vendorCode)
{
    QMutexLocker locker(&m_mutex);

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT mc.id FROM model_configs mc
        JOIN api_keys ak ON mc.api_key_id = ak.id
        JOIN model_vendors v ON ak.vendor_id = v.id
        WHERE v.code=? AND ak.is_default=1 AND mc.is_enabled=1 AND ak.is_enabled=1
        ORDER BY mc.is_favorite DESC, mc.sort_order ASC
        LIMIT 1
    )");
    query.addBindValue(vendorCode);

    if (!query.exec() || !query.next()) {
        return std::nullopt;
    }

    return getConfig(query.value(0).toInt());
}

std::optional<ModelConfigManager::RuntimeConfig> ModelConfigManager::getRuntimeConfig(int configId)
{
    QMutexLocker locker(&m_mutex);

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT mc.model_name, mc.parameters,
               ak.key_encrypted, v.default_base_url, mc.id
        FROM model_configs mc
        JOIN api_keys ak ON mc.api_key_id = ak.id
        JOIN model_vendors v ON ak.vendor_id = v.id
        WHERE mc.id=? AND mc.is_enabled=1 AND ak.is_enabled=1
    )");
    query.addBindValue(configId);

    if (!query.exec() || !query.next()) {
        return std::nullopt;
    }

    RuntimeConfig rt;
    rt.configId = configId;
    rt.modelName = query.value("model_name").toString();
    rt.baseUrl = query.value("default_base_url").toString();
    rt.parameters = QJsonDocument::fromJson(
                        query.value("parameters").toByteArray()
                        ).object();

    // 解密 key
    rt.apiKey = decrypt(query.value("key_encrypted").toByteArray());

    // 异步记录使用
    QMetaObject::invokeMethod(this, [this, configId]() {
        recordUsage(configId, 0);
    }, Qt::QueuedConnection);

    return rt;
}

// === 使用统计 ===
bool ModelConfigManager::recordUsage(int configId, int tokensUsed, int latencyMs)
{
    Q_UNUSED(latencyMs)  // 预留参数，未来可扩展

    QMutexLocker locker(&m_mutex);

    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE model_configs SET
            last_used_at = ?,
            usage_count = usage_count + 1,
            total_tokens = total_tokens + ?
        WHERE id = ?
    )");

    query.addBindValue(QDateTime::currentMSecsSinceEpoch());
    query.addBindValue(tokensUsed);
    query.addBindValue(configId);

    if (query.exec()) {
        // 同时更新 api_keys 的使用统计
        QSqlQuery keyQuery(m_db);
        keyQuery.prepare(R"(
            UPDATE api_keys SET
                last_used_at = ?,
                usage_count = usage_count + 1
            WHERE id = (SELECT api_key_id FROM model_configs WHERE id=?)
        )");
        keyQuery.addBindValue(QDateTime::currentMSecsSinceEpoch());
        keyQuery.addBindValue(configId);
        keyQuery.exec();

        emit configChanged(configId);
        return true;
    }

    return false;
}

QList<QObject*> ModelConfigManager::listVendorsQml()
{
    QList<QObject*> result;
    auto vendors = listVendors(); // 原有方法

    for (const auto &v : std::as_const(vendors)) {
        result.append(new VendorObject(v, this));
    }
    return result;
}

QList<QObject*> ModelConfigManager::listApiKeysQml(int vendorId, bool onlyEnabled)
{
    QList<QObject*> result;
    auto keys = listApiKeys(vendorId, onlyEnabled);

    for (const auto &k : std::as_const(keys)) {
        result.append(new ApiKeyObject(k, this));
    }
    return result;
}

QList<QObject*> ModelConfigManager::listConfigsQml(int vendorId, const QString &search, bool onlyEnabled)
{
    QList<QObject*> result;
    auto configs = listConfigs(vendorId, search, onlyEnabled, true);

    for (const auto &c : std::as_const(configs)) {
        result.append(new ModelConfigObject(c, this));
    }
    return result;
}

// QML 可用的操作方法
bool ModelConfigManager::addApiKeyQml(int vendorId, const QString &name,
                                      const QString &plainKey,
                                      const QJsonObject &options)
{
    ApiKey key;
    key.vendorId = vendorId;
    key.name = name;
    key.rateLimitPerMinute = options.value("rateLimitPerMinute").toInt();
    key.monthlyBudgetUsd = options.value("monthlyBudgetUsd").toDouble();

    bool success = addApiKey(key, plainKey);
    if (success) {
        emit apiKeysChanged();
    }
    return success;
}

bool ModelConfigManager::deleteApiKeyQml(int id)
{
    bool success = deleteApiKey(id);
    if (success) {
        emit apiKeysChanged();
    }
    return success;
}

bool ModelConfigManager::updateApiKeySecretQml(int id, const QString &newPlainKey)
{
    return updateApiKeySecret(id, newPlainKey);
}

bool ModelConfigManager::addConfigQml(int apiKeyId, const QString &displayName,
                                      const QString &modelName,
                                      const QJsonObject &parameters)
{
    ModelConfig config;
    config.apiKeyId = apiKeyId;
    config.displayName = displayName;
    config.modelName = modelName;
    config.parameters = parameters;

    bool success = addConfig(config);
    if (success) {
        emit configsChanged();
    }
    return success;
}

bool ModelConfigManager::deleteConfigQml(int id)
{
    bool success = deleteConfig(id);
    if (success) {
        emit configsChanged();
    }
    return success;
}

bool ModelConfigManager::toggleConfigFavoriteQml(int id, bool isFavorite)
{
    auto config = getConfig(id);
    if (!config) return false;

    config->isFavorite = isFavorite;
    bool success = updateConfig(*config);
    if (success) {
        emit configsChanged();
    }
    return success;
}

QString ModelConfigManager::decryptApiKeyQml(int id)
{
    return decryptApiKey(id);
}

QJsonObject ModelConfigManager::getRuntimeConfigQml(int configId)
{
    auto rt = getRuntimeConfig(configId);
    if (!rt) return QJsonObject();

    return QJsonObject{
        {"apiKey", rt->apiKey},
        {"baseUrl", rt->baseUrl},
        {"modelName", rt->modelName},
        {"parameters", rt->parameters},
        {"configId", rt->configId}
    };
}
