#ifndef TOOL_REGISTRY_H
#define TOOL_REGISTRY_H

#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include <qqml.h>

class ToolRegistry : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

public:
    static ToolRegistry* create(QQmlEngine *engine, QJSEngine *scriptEngine);

    Q_INVOKABLE QVariantList getToolDefinitions() const;
    Q_INVOKABLE QVariantMap executeTool(const QString &name, const QJsonObject &args);
    Q_INVOKABLE QStringList toolNames() const;
    Q_INVOKABLE bool hasTools() const;

signals:
    void toolExecutionStarted(const QString &name, const QJsonObject &args);
    void toolExecutionFinished(const QString &name, const QJsonObject &result);

private:
    explicit ToolRegistry(QObject *parent = nullptr);

    static ToolRegistry *s_instance;

    // Built-in tools
    QJsonObject executeCalculator(const QJsonObject &args);
    QJsonObject executeGetTime(const QJsonObject &args);
    QJsonObject executeReadFile(const QJsonObject &args);

    void registerBuiltinTools();
};

#endif
