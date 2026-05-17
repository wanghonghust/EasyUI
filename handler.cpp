#include "handler.h"
#include <QFile>
#include <QDir>
#include <QCoreApplication>

Handler::Handler(QObject *parent)
    : QObject{parent}
{}

QString Handler::readFile(const QString &path)
{
    QString filePath = path;
    if (filePath.startsWith("qrc:"))
        filePath = filePath.mid(4);

    // 1. 先尝试文件系统直接读取（开发模式优先，无需打包资源）
    QStringList fsCandidates;
    fsCandidates << filePath;
    if (filePath.startsWith("/")) {
        int secondSlash = filePath.indexOf("/", 1);
        if (secondSlash > 0)
            fsCandidates << filePath.mid(secondSlash);
    }
    fsCandidates << filePath.mid(filePath.lastIndexOf("/views"));

    for (const QString &candidate : fsCandidates) {
        QString fullPath = candidate;
        if (!fullPath.startsWith("/"))
            fullPath = "/" + fullPath;

        // 尝试多种基础路径
        QStringList basePaths;
        QString appDir = QCoreApplication::applicationDirPath();

        // 1) 应用目录本身（部署模式）
        basePaths << appDir;
        // 2) 应用目录 + EasyChat 子目录
        basePaths << appDir + "/EasyChat";
        // 3) 从 build/xxx/Debug 或 build/xxx/Release 向上回退到项目根（开发模式）
        QDir projectDir(appDir);
        if (projectDir.cdUp() && projectDir.cdUp() && projectDir.cdUp()) {
            basePaths << projectDir.absolutePath();
        }

        for (const QString &base : basePaths) {
            QString srcPath = base + fullPath;
            if (QFile::exists(srcPath)) {
                QFile file(srcPath);
                if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
                    QString content = QString::fromUtf8(file.readAll());
                    qDebug() << "[Handler::readFile] loaded from filesystem:" << srcPath << "size:" << content.length();
                    return content;
                }
            }
        }
    }

    // 2. 回退到 QRC 资源读取
    QStringList candidates;
    candidates << filePath;
    if (filePath.startsWith("/")) {
        int secondSlash = filePath.indexOf("/", 1);
        if (secondSlash > 0)
            candidates << filePath.mid(secondSlash);
    }
    candidates << "/qt-project.org/imports/EasyChat" + filePath;
    candidates << "/EasyChat" + filePath;
    candidates << "/EasyChat" + filePath;
    candidates << filePath.mid(filePath.lastIndexOf("/views"));

    for (const QString &candidate : candidates) {
        QString fullPath = ":" + candidate;
        if (QFile::exists(fullPath)) {
            QFile file(fullPath);
            if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
                QString content = QString::fromUtf8(file.readAll());
                qDebug() << "[Handler::readFile] loaded from qrc:" << candidate << "size:" << content.length();
                return content;
            }
        }
    }

    qDebug() << "[Handler::readFile] resource not found, tried fs:" << fsCandidates << "qrc:" << candidates;
    return "";
}
