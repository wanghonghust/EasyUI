#include "ToastManager.h"

ToastManager *ToastManager::s_instance = nullptr;

ToastManager::ToastManager(QObject *parent) : QObject(parent) {}

ToastManager::~ToastManager() {}

ToastManager* ToastManager::create(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    if (!s_instance) {
        s_instance = new ToastManager();
    }
    return s_instance;
}

QVariantList ToastManager::toasts() const { return m_toasts; }
int ToastManager::maxVisible() const { return m_maxVisible; }

void ToastManager::setMaxVisible(int n)
{
    if (m_maxVisible != n) {
        m_maxVisible = n;
        emit maxVisibleChanged();
    }
}

QString ToastManager::position() const { return m_position; }

void ToastManager::setPosition(const QString &pos)
{
    if (m_position != pos) {
        m_position = pos;
        emit positionChanged();
    }
}

bool ToastManager::showCloseButton() const { return m_showCloseButton; }

void ToastManager::setShowCloseButton(bool visible)
{
    if (m_showCloseButton != visible) {
        m_showCloseButton = visible;
        emit showCloseButtonChanged();
    }
}

void ToastManager::show(const QString &message, const QString &type, int duration)
{
    if (message.isEmpty()) return;

    QVariantMap item;
    item["id"] = m_nextId++;
    item["message"] = message;
    item["type"] = type;
    item["duration"] = duration;
    item["position"] = m_position;
    item["showCloseButton"] = m_showCloseButton;

    m_toasts.append(item);

    // Enforce maxVisible: remove oldest excess
    while (m_toasts.size() > m_maxVisible) {
        m_toasts.removeFirst();
    }

    emit toastsChanged();
}

void ToastManager::success(const QString &message, int duration) { show(message, "success", duration); }
void ToastManager::warning(const QString &message, int duration) { show(message, "warning", duration); }
void ToastManager::error(const QString &message, int duration)   { show(message, "error", duration); }
void ToastManager::info(const QString &message, int duration)    { show(message, "info", duration); }

void ToastManager::closeAll()
{
    m_toasts.clear();
    emit toastsChanged();
}

void ToastManager::remove(int index)
{
    if (index >= 0 && index < m_toasts.size()) {
        m_toasts.removeAt(index);
        emit toastsChanged();
    }
}

void ToastManager::removeById(int id)
{
    for (int i = 0; i < m_toasts.size(); ++i) {
        if (m_toasts[i].toMap().value("id").toInt() == id) {
            m_toasts.removeAt(i);
            emit toastsChanged();
            return;
        }
    }
}
