// views/codeeditor/FileIO.h
#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QString>

class FileIO : public QObject
{
    Q_OBJECT
public:
    explicit FileIO(QObject *parent = nullptr);

    Q_INVOKABLE QString readFile(const QString &fileUrl);
    Q_INVOKABLE bool writeFile(const QString &fileUrl, const QString &content);
    Q_INVOKABLE bool createFile(const QString &parentPath, const QString &fileName);
    Q_INVOKABLE bool createFolder(const QString &parentPath, const QString &folderName);
    Q_INVOKABLE bool renamePath(const QString &oldPath, const QString &newName);
    Q_INVOKABLE bool deletePath(const QString &path);
};

#endif
