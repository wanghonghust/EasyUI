#include "promptmanager.h"
#include <QSqlError>
#include <QSqlQuery>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QRegularExpression>
#include <QDateTime>
#include <QDebug>
#include <QDir>

PromptManager *PromptManager::s_instance = nullptr;

PromptManager* PromptManager::create(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    if (!s_instance)
        s_instance = new PromptManager();
    return s_instance;
}

PromptManager::PromptManager(QObject *parent)
    : QObject(parent)
    , m_connectionName(QStringLiteral("prompt_db"))
    , m_initialized(false)
{
}

PromptManager::~PromptManager()
{
    if (QSqlDatabase::contains(m_connectionName)) {
        {
            QMutexLocker lock(&m_mutex);
            QSqlDatabase::database(m_connectionName).close();
        }
        QSqlDatabase::removeDatabase(m_connectionName);
    }
}

bool PromptManager::initialize(const QString &dbPath, const QString &encryptionKey)
{
    Q_UNUSED(encryptionKey)
    QMutexLocker lock(&m_mutex);

    if (m_initialized) return true;

    QDir().mkpath(QFileInfo(dbPath).absolutePath());

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", m_connectionName);
    db.setDatabaseName(dbPath);
    db.setConnectOptions("QSQLITE_BUSY_TIMEOUT=5000");

    if (!db.open()) {
        qWarning() << "PromptManager: Failed to open database:" << db.lastError().text();
        emit error("Failed to open database: " + db.lastError().text());
        return false;
    }

    // Enable WAL mode for better concurrent access with ModelConfigManager
    QSqlQuery pragma(db);
    pragma.exec("PRAGMA journal_mode=WAL");
    pragma.exec("PRAGMA foreign_keys=ON");

    if (!createTable()) {
        emit error("Failed to create prompt_templates table");
        return false;
    }

    initDefaultPrompts();

    m_initialized = true;
    emit initializedChanged();
    return true;
}

bool PromptManager::createTable()
{
    QSqlDatabase db = QSqlDatabase::database(m_connectionName);
    QSqlQuery q(db);

    const QString sql = R"(
        CREATE TABLE IF NOT EXISTS prompt_templates (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            category TEXT DEFAULT '通用',
            tags TEXT DEFAULT '[]',
            is_favorite INTEGER DEFAULT 0,
            usage_count INTEGER DEFAULT 0,
            created_at INTEGER,
            updated_at INTEGER
        )
    )";

    if (!q.exec(sql)) {
        qWarning() << "PromptManager: createTable failed:" << q.lastError().text();
        return false;
    }

    q.exec("CREATE INDEX IF NOT EXISTS idx_prompt_category ON prompt_templates(category)");
    q.exec("CREATE INDEX IF NOT EXISTS idx_prompt_favorite ON prompt_templates(is_favorite)");
    return true;
}

bool PromptManager::initDefaultPrompts()
{
    QSqlDatabase db = QSqlDatabase::database(m_connectionName);
    QSqlQuery q(db);

    // Check if defaults already seeded
    q.exec("SELECT COUNT(*) FROM prompt_templates");
    if (q.next() && q.value(0).toInt() > 0) return true;

    qint64 now = QDateTime::currentSecsSinceEpoch();

    struct DefaultPrompt {
        QString title;
        QString content;
        QString category;
        QStringList tags;
    };

    const QList<DefaultPrompt> defaults = {
        {"代码审查", "请审查以下代码，指出潜在的问题、性能瓶颈和改进建议：\n\n```\n{{code}}\n```", "开发", {"code", "review"}},
        {"翻译助手", "请将以下文本翻译为{{target_lang}}：\n\n{{text}}", "通用", {"translation"}},
        {"内容总结", "请简洁地总结以下内容的核心要点：\n\n{{content}}", "通用", {"summary"}},
        {"Bug 分析", "我的代码出现以下错误，请帮我分析原因并给出修复方案：\n\n错误信息：{{error}}\n相关代码：\n```\n{{code}}\n```", "开发", {"debug", "code"}},
        {"API 文档生成", "请为以下{{language}}函数生成详细的API文档，包括参数说明、返回值、使用示例：\n\n```\n{{code}}\n```", "开发", {"docs", "code"}},
        {"写作润色", "请润色以下文本，使其更流畅专业，保持原意不变：\n\n{{text}}", "写作", {"writing"}},
        {"SQL 优化", "请分析以下SQL查询的性能问题并给出优化建议：\n\n```sql\n{{query}}\n```", "开发", {"sql", "database"}},
        {"正则表达式生成", "请生成一个正则表达式用于匹配{{description}}。请解释各部分的含义。", "开发", {"regex"}},
        {"解释概念", "请用简单易懂的方式解释「{{concept}}」是什么，并给出实际应用场景。", "学习", {"explanation"}},
        {"邮件撰写", "请帮我写一封邮件，收件人：{{recipient}}，主题：{{subject}}，要点：\n{{points}}", "写作", {"email"}},
        {"周报生成", "根据以下工作内容生成一份周报：\n\n本周完成：\n{{done}}\n\n下周计划：\n{{plan}}", "工作", {"report"}},
        {"角色扮演", "你是一个{{role}}。请用该角色的口吻和知识回答后续问题。", "通用", {"roleplay"}},
    };

    q.prepare("INSERT INTO prompt_templates (title, content, category, tags, is_favorite, usage_count, created_at, updated_at) "
              "VALUES (:title, :content, :category, :tags, 0, 0, :ts, :ts)");

    for (const auto &p : defaults) {
        q.bindValue(":title", p.title);
        q.bindValue(":content", p.content);
        q.bindValue(":category", p.category);
        q.bindValue(":tags", QJsonDocument(QJsonArray::fromStringList(p.tags)).toJson(QJsonDocument::Compact));
        q.bindValue(":ts", now);
        if (!q.exec())
            qWarning() << "PromptManager: seed failed for" << p.title << q.lastError().text();
    }

    return true;
}

// ============ QML-exposed query helpers ============

static QSqlDatabase promptDb()
{
    return QSqlDatabase::database(QStringLiteral("prompt_db"));
}

QVariantList PromptManager::listPrompts(const QString &category, const QString &search,
                                        bool favoritesFirst) const
{
    QMutexLocker lock(&m_mutex);
    QSqlDatabase db = promptDb();
    QSqlQuery q(db);

    QString sql = "SELECT * FROM prompt_templates WHERE 1=1";
    QStringList params;

    if (!category.isEmpty()) {
        sql += " AND category = :cat";
        params << category;
    }
    if (!search.isEmpty()) {
        sql += " AND (title LIKE :s1 OR content LIKE :s2 OR tags LIKE :s3)";
        params << search << search << search;
    }

    sql += " ORDER BY is_favorite DESC, ";
    if (favoritesFirst)
        sql += "is_favorite DESC, ";
    sql += "usage_count DESC, updated_at DESC";

    q.prepare(sql);
    for (int i = 0; i < params.size(); i++) {
        q.bindValue(QString(":%1").arg(i == 0 ? (category.isEmpty() ? "s1" : "cat") :
                       i == 0 ? "cat" : QString("s%1").arg(i)),
                    i == 0 && !category.isEmpty() ? category :
                    QString("%%1%").arg("%" + params[i] + "%"));
    }

    // Simpler approach: bind by explicit names
    QSqlQuery q2(db);
    QString finalSql = "SELECT * FROM prompt_templates WHERE 1=1";

    QVariantList bindValues;
    if (!category.isEmpty()) {
        finalSql += " AND category = ?";
        bindValues << category;
    }
    if (!search.isEmpty()) {
        finalSql += " AND (title LIKE ? OR content LIKE ? OR tags LIKE ?)";
        QString pattern = "%" + search + "%";
        bindValues << pattern << pattern << pattern;
    }
    finalSql += " ORDER BY is_favorite DESC, usage_count DESC, updated_at DESC";

    q2.prepare(finalSql);
    for (int i = 0; i < bindValues.size(); i++)
        q2.bindValue(i, bindValues[i]);

    q2.exec();

    QVariantList results;
    while (q2.next()) {
        QVariantMap row;
        row["id"] = q2.value("id");
        row["title"] = q2.value("title");
        row["content"] = q2.value("content");
        row["category"] = q2.value("category");

        QString tagsJson = q2.value("tags").toString();
        row["tags"] = QJsonDocument::fromJson(tagsJson.toUtf8()).array().toVariantList();

        row["isFavorite"] = q2.value("is_favorite").toBool();
        row["usageCount"] = q2.value("usage_count").toInt();
        row["createdAt"] = q2.value("created_at");
        row["updatedAt"] = q2.value("updated_at");
        results.append(row);
    }
    return results;
}

QVariantMap PromptManager::getPrompt(int id) const
{
    QMutexLocker lock(&m_mutex);
    QSqlDatabase db = promptDb();
    QSqlQuery q(db);
    q.prepare("SELECT * FROM prompt_templates WHERE id = ?");
    q.bindValue(0, id);
    q.exec();

    if (!q.next()) return {};

    QVariantMap row;
    row["id"] = q.value("id");
    row["title"] = q.value("title");
    row["content"] = q.value("content");
    row["category"] = q.value("category");
    QString tagsJson = q.value("tags").toString();
    row["tags"] = QJsonDocument::fromJson(tagsJson.toUtf8()).array().toVariantList();
    row["isFavorite"] = q.value("is_favorite").toBool();
    row["usageCount"] = q.value("usage_count").toInt();
    row["createdAt"] = q.value("created_at");
    row["updatedAt"] = q.value("updated_at");
    return row;
}

int PromptManager::addPrompt(const QString &title, const QString &content,
                              const QString &category, const QStringList &tags)
{
    if (title.trimmed().isEmpty() || content.trimmed().isEmpty()) {
        emit error("Title and content are required");
        return -1;
    }

    QMutexLocker lock(&m_mutex);
    QSqlDatabase db = promptDb();
    QSqlQuery q(db);
    qint64 now = QDateTime::currentSecsSinceEpoch();

    q.prepare("INSERT INTO prompt_templates (title, content, category, tags, created_at, updated_at) "
              "VALUES (?, ?, ?, ?, ?, ?)");
    q.bindValue(0, title.trimmed());
    q.bindValue(1, content.trimmed());
    q.bindValue(2, category.isEmpty() ? "通用" : category);
    q.bindValue(3, QJsonDocument(QJsonArray::fromStringList(tags)).toJson(QJsonDocument::Compact));
    q.bindValue(4, now);
    q.bindValue(5, now);

    if (!q.exec()) {
        emit error("Failed to add prompt: " + q.lastError().text());
        return -1;
    }

    int id = q.lastInsertId().toInt();
    emit promptAdded(id);
    emit promptsChanged();
    return id;
}

bool PromptManager::updatePrompt(int id, const QVariantMap &fields)
{
    QMutexLocker lock(&m_mutex);
    QSqlDatabase db = promptDb();
    QSqlQuery q(db);

    QStringList setClauses;
    QVariantList values;

    if (fields.contains("title")) {
        setClauses << "title = ?";
        values << fields["title"].toString();
    }
    if (fields.contains("content")) {
        setClauses << "content = ?";
        values << fields["content"].toString();
    }
    if (fields.contains("category")) {
        setClauses << "category = ?";
        values << fields["category"].toString();
    }
    if (fields.contains("tags")) {
        QStringList tags = fields["tags"].toStringList();
        setClauses << "tags = ?";
        values << QJsonDocument(QJsonArray::fromStringList(tags)).toJson(QJsonDocument::Compact);
    }

    if (setClauses.isEmpty()) return false;

    setClauses << "updated_at = ?";
    values << QDateTime::currentSecsSinceEpoch();

    QString sql = "UPDATE prompt_templates SET " + setClauses.join(", ") + " WHERE id = ?";
    values << id;

    q.prepare(sql);
    for (int i = 0; i < values.size(); i++)
        q.bindValue(i, values[i]);

    if (!q.exec()) {
        emit error("Failed to update prompt: " + q.lastError().text());
        return false;
    }

    if (q.numRowsAffected() > 0) {
        emit promptUpdated(id);
        emit promptsChanged();
    }
    return q.numRowsAffected() > 0;
}

bool PromptManager::deletePrompt(int id)
{
    QMutexLocker lock(&m_mutex);
    QSqlDatabase db = promptDb();
    QSqlQuery q(db);
    q.prepare("DELETE FROM prompt_templates WHERE id = ?");
    q.bindValue(0, id);

    if (!q.exec()) {
        emit error("Failed to delete prompt: " + q.lastError().text());
        return false;
    }

    if (q.numRowsAffected() > 0) {
        emit promptRemoved(id);
        emit promptsChanged();
    }
    return q.numRowsAffected() > 0;
}

bool PromptManager::toggleFavorite(int id)
{
    QMutexLocker lock(&m_mutex);
    QSqlDatabase db = promptDb();
    QSqlQuery q(db);
    q.prepare("UPDATE prompt_templates SET is_favorite = NOT is_favorite, updated_at = ? WHERE id = ?");
    q.bindValue(0, QDateTime::currentSecsSinceEpoch());
    q.bindValue(1, id);

    if (!q.exec()) return false;
    emit promptUpdated(id);
    emit promptsChanged();
    return true;
}

bool PromptManager::incrementUsage(int id)
{
    QMutexLocker lock(&m_mutex);
    QSqlDatabase db = promptDb();
    QSqlQuery q(db);
    q.prepare("UPDATE prompt_templates SET usage_count = usage_count + 1 WHERE id = ?");
    q.bindValue(0, id);
    return q.exec();
}

QStringList PromptManager::categories() const
{
    QMutexLocker lock(&m_mutex);
    QSqlDatabase db = promptDb();
    QSqlQuery q(db);
    q.exec("SELECT DISTINCT category FROM prompt_templates ORDER BY category");

    QStringList cats;
    while (q.next())
        cats << q.value(0).toString();
    return cats;
}

QString PromptManager::interpolateVariables(const QString &templateText,
                                             const QVariantMap &variables) const
{
    QString result = templateText;
    QRegularExpression re("\\{\\{(\\w+)\\}\\}");

    QRegularExpressionMatchIterator it = re.globalMatch(templateText);
    // Process in reverse to avoid offset issues with replacements of different lengths
    QList<QPair<int, QPair<int, QString>>> replacements; // pos, len, newText

    while (it.hasNext()) {
        auto match = it.next();
        QString varName = match.captured(1);
        QString replacement = variables.value(varName).toString();
        replacements.append({(int)match.capturedStart(), {(int)match.capturedLength(), replacement}});
    }

    // Apply replacements in reverse order
    std::reverse(replacements.begin(), replacements.end());
    for (const auto &r : replacements) {
        result.replace(r.first, r.second.first, r.second.second);
    }

    return result;
}

QString PromptManager::exportPromptsJson() const
{
    QMutexLocker lock(&m_mutex);

    QVariantList prompts = listPrompts();

    QJsonObject root;
    root["version"] = "1.0";
    root["exportTime"] = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);
    root["count"] = prompts.size();

    QJsonArray arr;
    for (const auto &p : prompts) {
        arr.append(QJsonObject::fromVariantMap(p.toMap()));
    }
    root["prompts"] = arr;

    return QJsonDocument(root).toJson(QJsonDocument::Indented);
}

bool PromptManager::importPromptsJson(const QString &json)
{
    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8(), &err);
    if (err.error != QJsonParseError::NoError) {
        emit error("JSON parse error: " + err.errorString());
        return false;
    }

    QJsonObject root = doc.object();
    QJsonArray prompts = root["prompts"].toArray();

    int count = 0;
    for (const auto &val : prompts) {
        QJsonObject obj = val.toObject();
        int id = addPrompt(
            obj["title"].toString(),
            obj["content"].toString(),
            obj["category"].toString("通用"),
            obj["tags"].toVariant().toStringList()
        );
        if (id > 0) count++;
    }

    return count > 0;
}
