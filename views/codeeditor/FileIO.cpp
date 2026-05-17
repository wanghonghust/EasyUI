// EasyUI/src/FileIO.cpp
#include "FileIO.h"
#include <QFile>
#include <QDir>
#include <QUrl>
#include <QFileInfo>
#include <QTextStream>

FileIO::FileIO(QObject *parent)
    : QObject(parent)
{
}

static QString toLocalPath(const QString &urlOrPath)
{
    QString path = QUrl(urlOrPath).toLocalFile();
    return path.isEmpty() ? urlOrPath : path;
}

QString FileIO::readFile(const QString &fileUrl)
{
    QString path = toLocalPath(fileUrl);

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return QString();

    QTextStream in(&file);
    in.setEncoding(QStringConverter::Utf8);
    QString content = in.readAll();
    file.close();
    return content;
}

bool FileIO::writeFile(const QString &fileUrl, const QString &content)
{
    QString path = toLocalPath(fileUrl);

    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return false;

    QTextStream out(&file);
    out.setEncoding(QStringConverter::Utf8);
    out << content;
    file.close();
    return true;
}

bool FileIO::createFile(const QString &parentPath, const QString &fileName)
{
    QString dir = toLocalPath(parentPath);
    QString filePath = QDir(dir).absoluteFilePath(fileName);

    QFile file(filePath);
    if (file.exists())
        return false;
    if (!file.open(QIODevice::WriteOnly))
        return false;
    file.close();
    return true;
}

bool FileIO::createFolder(const QString &parentPath, const QString &folderName)
{
    QString dir = toLocalPath(parentPath);
    QString folderPath = QDir(dir).absoluteFilePath(folderName);

    QDir qdir;
    return qdir.mkdir(folderPath);
}

bool FileIO::renamePath(const QString &oldPath, const QString &newName)
{
    QString old = toLocalPath(oldPath);
    QFileInfo info(old);
    QString newPath = info.absoluteDir().absoluteFilePath(newName);

    if (QFileInfo::exists(newPath))
        return false;

    QDir qdir;
    return qdir.rename(old, newPath);
}

bool FileIO::deletePath(const QString &path)
{
    QString p = toLocalPath(path);
    QFileInfo info(p);

    if (!info.exists())
        return false;

    if (info.isDir())
        return QDir(p).removeRecursively();
    else
        return QFile::remove(p);
}
