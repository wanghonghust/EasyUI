#ifndef DYNAMICTABLEMODEL_H
#define DYNAMICTABLEMODEL_H

#include <QAbstractTableModel>
#include <QQmlEngine>
#include <QVariantList>
#include <QVariantMap>

class DynamicTableModel : public QAbstractTableModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QVariantList rows READ rows WRITE setRows NOTIFY rowsChanged)
    Q_PROPERTY(QStringList columns READ columns WRITE setColumns NOTIFY columnsChanged)

public:
    explicit DynamicTableModel(QObject *parent = nullptr);

    // 列操作
    Q_INVOKABLE void addColumn(const QString &displayRole);
    Q_INVOKABLE void insertColumn(int index, const QString &displayRole);
    Q_INVOKABLE void removeColumn(int index);
    Q_INVOKABLE void clearColumns();
    Q_INVOKABLE void setColumns(const QStringList &displayRoles);
    QStringList columns() const;

    // 数据操作
    Q_INVOKABLE void addRow(const QVariantMap &row);
    Q_INVOKABLE void insertRow(int index, const QVariantMap &row);
    Q_INVOKABLE void removeRow(int index);
    Q_INVOKABLE void clearRows();
    Q_INVOKABLE QVariantMap getRow(int index) const;
    Q_INVOKABLE void setRows(const QVariantList &rows);

    // QAbstractTableModel 接口
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QVariantList rows() const;

signals:
    void rowsChanged();
    void columnsChanged();

private:
    QStringList m_displayRoles;  // 列的角色名列表（name, age, email...）
    QVariantList m_rows;
};

#endif