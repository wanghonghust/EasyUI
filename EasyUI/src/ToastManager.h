#ifndef TOASTMANAGER_H
#define TOASTMANAGER_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QQmlEngine>
#include <QJSEngine>

class ToastManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariantList toasts READ toasts NOTIFY toastsChanged)
    Q_PROPERTY(int maxVisible READ maxVisible WRITE setMaxVisible NOTIFY maxVisibleChanged)
    Q_PROPERTY(QString position READ position WRITE setPosition NOTIFY positionChanged)
    Q_PROPERTY(bool showCloseButton READ showCloseButton WRITE setShowCloseButton NOTIFY showCloseButtonChanged)

public:
    static ToastManager* create(QQmlEngine *engine, QJSEngine *scriptEngine);

    QVariantList toasts() const;
    int maxVisible() const;
    void setMaxVisible(int n);
    QString position() const;
    void setPosition(const QString &pos);
    bool showCloseButton() const;
    void setShowCloseButton(bool visible);

    Q_INVOKABLE void show(const QString &message, const QString &type = "info", int duration = 3000);
    Q_INVOKABLE void success(const QString &message, int duration = 3000);
    Q_INVOKABLE void warning(const QString &message, int duration = 3000);
    Q_INVOKABLE void error(const QString &message, int duration = 3000);
    Q_INVOKABLE void info(const QString &message, int duration = 3000);
    Q_INVOKABLE void closeAll();
    Q_INVOKABLE void remove(int index);
    Q_INVOKABLE void removeById(int id);

signals:
    void toastsChanged();
    void maxVisibleChanged();
    void positionChanged();
    void showCloseButtonChanged();

private:
    explicit ToastManager(QObject *parent = nullptr);
    ~ToastManager();

    static ToastManager *s_instance;

    QVariantList m_toasts;
    int m_maxVisible = 5;
    QString m_position = "top-center";
    bool m_showCloseButton = true;
    int m_nextId = 1;
};

#endif
