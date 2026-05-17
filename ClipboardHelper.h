#ifndef CLIPBOARDHELPER_H
#define CLIPBOARDHELPER_H

#include <QObject>
#include <QClipboard>
#include <QGuiApplication>
#include <QMimeData>
#include <QImage>
#include <QBuffer>
#include <QUrl>

class ClipboardHelper : public QObject {
    Q_OBJECT
public:
    explicit ClipboardHelper(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE void setText(const QString &text) {
        QGuiApplication::clipboard()->setText(text);
    }

    Q_INVOKABLE QString text() const {
        return QGuiApplication::clipboard()->text();
    }

    Q_INVOKABLE bool hasImage() const {
        const QMimeData *mime = QGuiApplication::clipboard()->mimeData();
        return mime && mime->hasImage();
    }

    Q_INVOKABLE QString imageBase64() const {
        const QMimeData *mime = QGuiApplication::clipboard()->mimeData();
        if (!mime || !mime->hasImage()) return {};

        QImage img = qvariant_cast<QImage>(mime->imageData());
        if (img.isNull()) return {};

        // Resize to max 2048px on longest side
        if (img.width() > 2048 || img.height() > 2048) {
            img = img.scaled(2048, 2048, Qt::KeepAspectRatio, Qt::SmoothTransformation);
        }

        QByteArray data;
        QBuffer buf(&data);
        buf.open(QIODevice::WriteOnly);
        img.save(&buf, "PNG");

        return "data:image/png;base64," + data.toBase64();
    }

    Q_INVOKABLE QVariantMap imageInfo() const {
        const QMimeData *mime = QGuiApplication::clipboard()->mimeData();
        if (!mime || !mime->hasImage()) return {};

        QImage img = qvariant_cast<QImage>(mime->imageData());
        if (img.isNull()) return {};

        QVariantMap info;
        info["width"] = img.width();
        info["height"] = img.height();
        info["name"] = "clipboard_image.png";
        info["type"] = "image";
        info["mimeType"] = "image/png";
        info["data"] = imageBase64();
        return info;
    }

    Q_INVOKABLE QVariantList filePathsFromClipboard() const {
        QVariantList paths;
        const QMimeData *mime = QGuiApplication::clipboard()->mimeData();
        if (!mime) return paths;
        for (const QUrl &url : mime->urls()) {
            if (url.isLocalFile())
                paths << url.toLocalFile();
        }
        return paths;
    }
};

#endif
