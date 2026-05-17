#ifndef FILETREEMODEL_H
#define FILETREEMODEL_H

#include <QObject>
#include <QVariantList>

class FileTreeModel : public QObject
{
    Q_OBJECT
public:
    explicit FileTreeModel(QObject *parent = nullptr);

    Q_INVOKABLE QVariantList buildTree(const QString &rootPath);

private:
    QVariantList buildTreeRecursive(const QString &dirPath);
};

#endif
