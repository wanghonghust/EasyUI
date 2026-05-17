#include "FileTreeModel.h"
#include <QDir>
#include <QFileInfo>
#include <QUrl>

FileTreeModel::FileTreeModel(QObject *parent)
    : QObject(parent)
{
}

QVariantList FileTreeModel::buildTree(const QString &rootPath)
{
    QString path = QUrl(rootPath).toLocalFile();
    if (path.isEmpty())
        path = rootPath;

    QDir dir(path);
    if (!dir.exists())
        return {};

    return buildTreeRecursive(path);
}

QVariantList FileTreeModel::buildTreeRecursive(const QString &dirPath)
{
    QDir dir(dirPath);
    QVariantList result;

    const auto entries = dir.entryInfoList(
        QDir::NoDotAndDotDot | QDir::Dirs | QDir::Files,
        QDir::DirsFirst | QDir::Name);

    for (const QFileInfo &info : entries) {
        QVariantMap item;
        item["label"] = info.fileName();
        item["path"] = info.absoluteFilePath();

        if (info.isDir()) {
            if (info.isSymLink())
                continue;
            item["icon"] = QStringLiteral(""); // folder
            item["children"] = buildTreeRecursive(info.absoluteFilePath());
        } else {
            item["icon"] = QStringLiteral(""); // description
        }

        result.append(item);
    }

    return result;
}
