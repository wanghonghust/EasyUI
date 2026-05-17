#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QFontDatabase>
#include <QFont>

#include "handler.h"
#include "src/EasyUI.h"
#include "ModelConfigManager.h"
#include "ClipboardHelper.h"
#include "views/codeeditor/FileIO.h"
#include "views/codeeditor/FileTreeModel.h"

#include "openapi/chatmanager.h"
#include "openapi/promptmanager.h"
#include "openapi/chatsession.h"
#include "openapi/websearchmanager.h"
#include "openapi/toolregistry.h"
#include "openapi/chatmessage.h"
#include "openapi/openaiconfig.h"


int main(int argc, char *argv[])
{
    // 高 DPI 支持（必须在 QGuiApplication 创建之前设置）
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

    QGuiApplication app(argc, argv);
    
    // 设置全局字体，避免 Qt 回退到 Fixedsys
    QFont font("Microsoft YaHei, Segoe UI, sans-serif");
    font.setStyleHint(QFont::SansSerif);
    app.setFont(font);

    // 设置组织信息（Settings 需要）
    QCoreApplication::setOrganizationName("EasyChat");
    QCoreApplication::setOrganizationDomain("easychat.app");

    QQuickStyle::setFallbackStyle("Basic");

    QQmlApplicationEngine engine;

    ModelConfigManager::registerQml();

    const QUrl url(QStringLiteral("qrc:/EasyChat/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    Handler handler;
    EasyUI::initialize(&engine);
    qmlRegisterSingletonInstance("Handler", 1, 0, "Handler", &handler);
    qmlRegisterSingletonType<ClipboardHelper>(
        "Utils", 1, 0, "Clipboard",
        [](QQmlEngine*, QJSEngine*) -> QObject* {
            return new ClipboardHelper();
        }
        );
    qmlRegisterType<FileIO>("Utils", 1, 0, "FileIO");
    qmlRegisterType<FileTreeModel>("Utils", 1, 0, "FileTreeModel");

    qmlRegisterSingletonType<ChatManager>("Chat", 1, 0, "ChatManager",
                                          &ChatManager::create);
    qmlRegisterUncreatableType<ChatSession>("Chat", 1, 0, "ChatSession",
                                            "Use ChatManager to create sessions");
    qmlRegisterUncreatableType<ChatMessage>("Chat", 1, 0, "ChatMessage",
                                            "Use ChatSession to create messages");
    qmlRegisterUncreatableType<OpenAIConfig>("Chat", 1, 0, "OpenAIConfig",
                                             "Use ChatManager or ChatSession to access config");
    qmlRegisterSingletonType<PromptManager>("Chat", 1, 0, "PromptManager",
                                             &PromptManager::create);
    qmlRegisterSingletonType<WebSearchManager>("Chat", 1, 0, "WebSearchManager",
                                                [](QQmlEngine*, QJSEngine*) -> QObject* {
                                                    return new WebSearchManager();
                                                });
    qmlRegisterSingletonType<ToolRegistry>("Chat", 1, 0, "ToolRegistry",
                                            &ToolRegistry::create);

    engine.load(url);

    return app.exec();
}
