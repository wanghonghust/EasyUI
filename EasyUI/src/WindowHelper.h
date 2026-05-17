// EasyUI/src/WindowHelper.h
#ifndef WINDOWHELPER_H
#define WINDOWHELPER_H

#include <QObject>
#include <QQuickWindow>
#include <QTimer>

class WindowHelper : public QObject
{
    Q_OBJECT
public:
    explicit WindowHelper(QObject *parent = nullptr);

    Q_INVOKABLE void fixGeometry(QQuickWindow *window);
};

#endif