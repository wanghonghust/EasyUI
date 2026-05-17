#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QFont>

#include <EasyUI.h>

int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QFont font("Microsoft YaHei, Segoe UI, sans-serif");
    font.setStyleHint(QFont::SansSerif);
    app.setFont(font);

    QCoreApplication::setOrganizationName("EasyUI_Demo");
    QQuickStyle::setFallbackStyle("Basic");

    QQmlApplicationEngine engine;
    EasyUI::initialize(&engine);
    engine.load(QUrl(QStringLiteral("qrc:/Demo/main.qml")));

    return app.exec();
}
