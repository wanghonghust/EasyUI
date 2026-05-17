#ifndef HANDLER_H
#define HANDLER_H

#include <QObject>
#include <QDebug>

class Handler : public QObject
{
    Q_OBJECT
    // 定义属性：名字、类型、读、写、信号
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)

public:
    Q_INVOKABLE QString name() { return m_name; }
    Q_INVOKABLE void setName(QString n) {
        m_name = n;
        qDebug() << n;
        emit nameChanged();
    }
    Q_INVOKABLE QString readFile(const QString &path);

signals:
    void nameChanged();  // 属性变化信号

private:
    QString m_name = "默认名字";

public:
    explicit Handler(QObject *parent = nullptr);


};

#endif // HANDLER_H
