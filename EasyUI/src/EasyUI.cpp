#include "EasyUI.h"
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QWKQuick/qwkquickglobal.h>
#include "DynamicTableModel.h"
#include "markdown/CodeHighlighter.h"
#include "markdown/MarkdownDocument.h"
#include "markdown/MarkdownSelectionHandler.h"
#include "markdown/MarkdownStyle.h"
#include "WindowHelper.h"
#include "ToastManager.h"

void EasyUI::initialize(QQmlApplicationEngine *engine)
{
    if (!engine) return;

    QWK::registerTypes(engine);
    qmlRegisterType<DynamicTableModel>("DynamicTableModel", 1, 0, "DynamicTableModel");
    qmlRegisterType<CodeHighlighter>("CodeHighlighter", 1, 0, "CodeHighlighter");
    qmlRegisterType<WindowHelper>("EasyUI", 1, 0, "WindowHelper");
    qmlRegisterType<MarkdownStyle>("EasyUI", 1, 0, "MarkdownStyle");
    qmlRegisterType<MarkdownDocument>("EasyUI", 1, 0, "MarkdownDocument");
    qmlRegisterType<MarkdownSelectionHandler>("EasyUI", 1, 0, "MarkdownSelectionHandler");
    qmlRegisterSingletonType<ToastManager>("EasyUI", 1, 0, "ToastManager", &ToastManager::create);

    // Create QML singletons explicitly. Qt 6's auto-generated qmldir correctly
    // marks them as singletons, but cross-singleton property bindings (e.g.
    // EasyTheme.isDark → ThemeSettings.isDark) may not resolve when the engine
    // auto-instantiates them in an undetermined order.
    auto singleton = [engine](const char *uri, const char *typeName, const QString &qmlPath) {
        QQmlComponent c(engine, QUrl(qmlPath));
        if (c.isError()) {
            qWarning() << "EasyUI: singleton load error" << qmlPath << c.errorString();
            return;
        }
        QObject *obj = c.create();
        if (obj)
            qmlRegisterSingletonInstance(uri, 1, 0, typeName, obj);
        else
            qWarning() << "EasyUI: singleton create error" << qmlPath << c.errorString();
    };

    // Order: ThemeSettings → EasyTheme (binding: EasyTheme.isDark → ThemeSettings.isDark)
    singleton("EasyUI", "ThemeSettings", QStringLiteral("qrc:/EasyUI/qml/theme/ThemeSettings.qml"));
    singleton("EasyUI", "EasyTheme",     QStringLiteral("qrc:/EasyUI/qml/theme/EasyTheme.qml"));
    singleton("EasyUI", "EasyIcon",      QStringLiteral("qrc:/EasyUI/qml/basic/EasyIcon.qml"));
}
