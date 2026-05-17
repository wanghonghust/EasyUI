#ifndef WEBSEARCH_MANAGER_H
#define WEBSEARCH_MANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QVariantList>
#include <qqml.h>

class WebSearchManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString provider READ provider WRITE setProvider NOTIFY providerChanged)
    Q_PROPERTY(QString apiKey READ apiKey WRITE setApiKey NOTIFY apiKeyChanged)
    Q_PROPERTY(int maxResults READ maxResults WRITE setMaxResults NOTIFY maxResultsChanged)
    Q_PROPERTY(bool isSearching READ isSearching NOTIFY isSearchingChanged)

public:
    explicit WebSearchManager(QObject *parent = nullptr);
    ~WebSearchManager();

    QString provider() const;
    void setProvider(const QString &p);
    QString apiKey() const;
    void setApiKey(const QString &key);
    int maxResults() const;
    void setMaxResults(int n);
    bool isSearching() const;

    Q_INVOKABLE void search(const QString &query);
    Q_INVOKABLE void cancelSearch();

    static QVariantList formatResultsAsContext(const QVariantList &results, const QString &query);

signals:
    void providerChanged();
    void apiKeyChanged();
    void maxResultsChanged();
    void isSearchingChanged();
    void searchCompleted(const QVariantList &results);
    void searchError(const QString &error);

private:
    QNetworkAccessManager *m_network;
    QNetworkReply *m_reply;
    QString m_provider;
    QString m_apiKey;
    int m_maxResults;
    bool m_isSearching;

    void parseTavilyResponse(const QByteArray &data, QVariantList &results);
};

#endif
