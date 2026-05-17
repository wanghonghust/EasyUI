#ifndef PROMPT_MANAGER_H
#define PROMPT_MANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QMutex>
#include <QJsonObject>
#include <qqml.h>

class PromptManager : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

    Q_PROPERTY(bool initialized READ isInitialized NOTIFY initializedChanged)

public:
    static PromptManager* create(QQmlEngine *engine, QJSEngine *scriptEngine);

    bool isInitialized() const { return m_initialized; }

    Q_INVOKABLE bool initialize(const QString &dbPath, const QString &encryptionKey = QString());

    // Prompt CRUD
    Q_INVOKABLE QVariantList listPrompts(const QString &category = QString(),
                                         const QString &search = QString(),
                                         bool favoritesFirst = true) const;
    Q_INVOKABLE QVariantMap getPrompt(int id) const;
    Q_INVOKABLE int addPrompt(const QString &title, const QString &content,
                               const QString &category = QString(),
                               const QStringList &tags = QStringList());
    Q_INVOKABLE bool updatePrompt(int id, const QVariantMap &fields);
    Q_INVOKABLE bool deletePrompt(int id);
    Q_INVOKABLE bool toggleFavorite(int id);
    Q_INVOKABLE bool incrementUsage(int id);

    // Categories & helpers
    Q_INVOKABLE QStringList categories() const;
    Q_INVOKABLE QString interpolateVariables(const QString &templateText,
                                              const QVariantMap &variables) const;

    // Import / Export
    Q_INVOKABLE QString exportPromptsJson() const;
    Q_INVOKABLE bool importPromptsJson(const QString &json);

signals:
    void initializedChanged();
    void promptsChanged();
    void promptAdded(int id);
    void promptUpdated(int id);
    void promptRemoved(int id);
    void error(const QString &message);

private:
    explicit PromptManager(QObject *parent = nullptr);
    ~PromptManager();

    static PromptManager *s_instance;

    bool createTable();
    bool initDefaultPrompts();

    QString m_connectionName;
    mutable QMutex m_mutex;
    bool m_initialized = false;
};

#endif
