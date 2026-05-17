#include "toolregistry.h"
#include <QJSEngine>
#include <QFile>
#include <QDateTime>
#include <QDebug>

ToolRegistry *ToolRegistry::s_instance = nullptr;

ToolRegistry* ToolRegistry::create(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine) Q_UNUSED(scriptEngine)
    if (!s_instance) {
        s_instance = new ToolRegistry();
        s_instance->registerBuiltinTools();
    }
    return s_instance;
}

ToolRegistry::ToolRegistry(QObject *parent) : QObject(parent)
{
    registerBuiltinTools();
}

void ToolRegistry::registerBuiltinTools()
{
    // Tools are registered statically — definitions returned by getToolDefinitions()
}

bool ToolRegistry::hasTools() const { return true; }

QStringList ToolRegistry::toolNames() const
{
    return {"calculator", "get_current_time"};
}

QVariantList ToolRegistry::getToolDefinitions() const
{
    QVariantList tools;

    {
        QVariantMap tool;
        tool["type"] = "function";
        QVariantMap func;
        func["name"] = "calculator";
        func["description"] = "Evaluate a mathematical expression. Use for any calculation.";
        QJsonObject params;
        QJsonObject exprProp;
        exprProp["type"] = "string";
        exprProp["description"] = "The mathematical expression to evaluate, e.g. '2+3*4'";
        QJsonObject props;
        props["expression"] = exprProp;
        params["type"] = "object";
        params["properties"] = props;
        params["required"] = QJsonArray{"expression"};
        func["parameters"] = QJsonValue::fromVariant(params.toVariantMap());
        tool["function"] = func;
        tools.append(tool);
    }

    {
        QVariantMap tool;
        tool["type"] = "function";
        QVariantMap func;
        func["name"] = "get_current_time";
        func["description"] = "Get the current date and time. Use when the user asks about current time.";
        QJsonObject params;
        params["type"] = "object";
        params["properties"] = QJsonObject{};
        func["parameters"] = QJsonValue::fromVariant(params.toVariantMap());
        tool["function"] = func;
        tools.append(tool);
    }

    return tools;
}

QVariantMap ToolRegistry::executeTool(const QString &name, const QJsonObject &args)
{
    emit toolExecutionStarted(name, args);

    QVariantMap result;
    if (name == "calculator") {
        QJsonObject r = executeCalculator(args);
        result = r.toVariantMap();
    } else if (name == "get_current_time") {
        QJsonObject r = executeGetTime(args);
        result = r.toVariantMap();
    } else {
        result["error"] = "Unknown tool: " + name;
    }

    emit toolExecutionFinished(name, QJsonObject::fromVariantMap(result));
    return result;
}

QJsonObject ToolRegistry::executeCalculator(const QJsonObject &args)
{
    QString expr = args["expression"].toString();
    QJsonObject result;

    // Safe evaluation using QJSEngine
    QJSEngine engine;
    QJSValue val = engine.evaluate(expr);
    if (val.isError()) {
        result["error"] = val.toString();
    } else {
        result["result"] = val.toVariant().toDouble();
        result["expression"] = expr;
    }
    return result;
}

QJsonObject ToolRegistry::executeGetTime(const QJsonObject &args)
{
    Q_UNUSED(args)
    QJsonObject result;
    result["datetime"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    result["timestamp"] = QDateTime::currentSecsSinceEpoch();
    result["timezone"] = QDateTime::currentDateTime().timeZoneAbbreviation();
    return result;
}

QJsonObject ToolRegistry::executeReadFile(const QJsonObject &args)
{
    QString path = args["path"].toString();
    QJsonObject result;
    // Sanitize: only allow relative paths within app dir
    if (path.contains("..") || path.startsWith("/") || path.contains(":\\")) {
        result["error"] = "Access denied: only relative paths allowed";
        return result;
    }
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        result["error"] = "Cannot read file: " + file.errorString();
        return result;
    }
    QString content = file.read(10000); // max 10KB
    file.close();
    result["content"] = content;
    result["size"] = content.size();
    return result;
}
