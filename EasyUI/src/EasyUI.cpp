#include "EasyUI.h"
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlNetworkAccessManagerFactory>
#include <QWKQuick/qwkquickglobal.h>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QHttp2Configuration>
#include "DynamicTableModel.h"
#include "markdown/CodeHighlighter.h"
#include "markdown/MarkdownDocument.h"
#include "markdown/MarkdownSelectionHandler.h"
#include "markdown/MarkdownStyle.h"
#include "WindowHelper.h"
#include "ToastManager.h"

// Custom QNetworkAccessManager that disables HTTP/2 on all requests,
// avoiding protocol errors with servers like GitHub's CDN.
class NoHttp2NetworkAccessManager : public QNetworkAccessManager {
public:
    explicit NoHttp2NetworkAccessManager(QObject *parent = nullptr)
        : QNetworkAccessManager(parent) {}

protected:
    QNetworkReply *createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData = nullptr) override {
        QNetworkRequest req(request);
        req.setAttribute(QNetworkRequest::Http2AllowedAttribute, false);
        return QNetworkAccessManager::createRequest(op, req, outgoingData);
    }
};

// Factory that creates NoHttp2NetworkAccessManager instances
class NoHttp2NamFactory : public QQmlNetworkAccessManagerFactory {
public:
    QNetworkAccessManager *create(QObject *parent) override {
        return new NoHttp2NetworkAccessManager(parent);
    }
};

void EasyUI::initialize(QQmlApplicationEngine *engine)
{
    if (!engine) return;

    // Install custom NAM factory that disables HTTP/2 globally for all QML network requests
    static NoHttp2NamFactory namFactory;
    engine->setNetworkAccessManagerFactory(&namFactory);

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
