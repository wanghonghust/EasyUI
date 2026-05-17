// EasyUI/src/WindowHelper.cpp
#include "WindowHelper.h"

WindowHelper::WindowHelper(QObject *parent)
    : QObject(parent)
{
}

void WindowHelper::fixGeometry(QQuickWindow *window)
{
    if (!window)
        return;

    QRect geom = window->geometry();
    window->setGeometry(QRect(0, 0, 0, 0));

    QTimer::singleShot(0, this, [=]() {
        window->setGeometry(geom.adjusted(1, 0, 0, 0));
        QTimer::singleShot(0, this, [=]() {
            window->setGeometry(geom);
        });
    });
}