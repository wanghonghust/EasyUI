#include "websearchmanager.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkRequest>
#include <QUrl>
#include <QDebug>

WebSearchManager::WebSearchManager(QObject *parent)
    : QObject(parent)
    , m_network(new QNetworkAccessManager(this))
    , m_reply(nullptr)
    , m_provider("tavily")
    , m_maxResults(5)
    , m_isSearching(false)
{
}

WebSearchManager::~WebSearchManager()
{
    cancelSearch();
}

QString WebSearchManager::provider() const { return m_provider; }
void WebSearchManager::setProvider(const QString &p) {
    if (m_provider != p) { m_provider = p; emit providerChanged(); }
}
QString WebSearchManager::apiKey() const { return m_apiKey; }
void WebSearchManager::setApiKey(const QString &key) {
    if (m_apiKey != key) { m_apiKey = key; emit apiKeyChanged(); }
}
int WebSearchManager::maxResults() const { return m_maxResults; }
void WebSearchManager::setMaxResults(int n) {
    if (m_maxResults != n && n > 0) { m_maxResults = n; emit maxResultsChanged(); }
}
bool WebSearchManager::isSearching() const { return m_isSearching; }

void WebSearchManager::cancelSearch()
{
    if (m_reply) {
        m_reply->abort();
        m_reply->deleteLater();
        m_reply = nullptr;
    }
    if (m_isSearching) {
        m_isSearching = false;
        emit isSearchingChanged();
    }
}

void WebSearchManager::search(const QString &query)
{
    if (m_isSearching) cancelSearch();
    if (query.trimmed().isEmpty()) return;

    if (m_provider == "tavily") {
        QUrl url("https://api.tavily.com/search");
        QNetworkRequest req(url);
        req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        if (!m_apiKey.isEmpty())
            req.setRawHeader("Authorization", ("Bearer " + m_apiKey).toUtf8());

        QJsonObject body;
        body["query"] = query;
        body["max_results"] = m_maxResults;
        body["search_depth"] = "basic";

        m_isSearching = true;
        emit isSearchingChanged();

        m_reply = m_network->post(req, QJsonDocument(body).toJson(QJsonDocument::Compact));
        connect(m_reply, &QNetworkReply::finished, this, [this]() {
            QVariantList results;
            if (m_reply->error() == QNetworkReply::NoError) {
                parseTavilyResponse(m_reply->readAll(), results);
                emit searchCompleted(results);
            } else {
                QString err = m_reply->errorString();
                emit searchError(err);
                qWarning() << "WebSearch error:" << err;
            }
            m_reply->deleteLater();
            m_reply = nullptr;
            m_isSearching = false;
            emit isSearchingChanged();
        });
    } else {
        QVariantList results;
        emit searchCompleted(results);
    }
}

void WebSearchManager::parseTavilyResponse(const QByteArray &data, QVariantList &results)
{
    QJsonDocument doc = QJsonDocument::fromJson(data);
    QJsonArray arr = doc.object()["results"].toArray();
    for (const auto &val : arr) {
        QJsonObject r = val.toObject();
        QVariantMap item;
        item["title"] = r["title"].toString();
        item["url"] = r["url"].toString();
        item["content"] = r["content"].toString();
        item["score"] = r["score"].toDouble();
        results.append(item);
    }
}

QVariantList WebSearchManager::formatResultsAsContext(const QVariantList &results, const QString &query)
{
    Q_UNUSED(query)
    return results;
}
