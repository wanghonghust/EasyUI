#include "DynamicTableModel.h"
#include <QDebug>

DynamicTableModel::DynamicTableModel(QObject *parent)
    : QAbstractTableModel(parent)
{
}

void DynamicTableModel::addColumn(const QString &displayRole)
{
    insertColumn(m_displayRoles.size(), displayRole);
}

void DynamicTableModel::insertColumn(int index, const QString &displayRole)
{
    if (index < 0 || index > m_displayRoles.size()) {
        qWarning() << "Invalid column index:" << index;
        return;
    }

    beginInsertColumns(QModelIndex(), index, index);
    m_displayRoles.insert(index, displayRole);
    endInsertColumns();

    emit columnsChanged();
}

void DynamicTableModel::removeColumn(int index)
{
    if (index < 0 || index >= m_displayRoles.size()) {
        qWarning() << "Invalid column index:" << index;
        return;
    }

    beginRemoveColumns(QModelIndex(), index, index);
    m_displayRoles.removeAt(index);
    endRemoveColumns();

    emit columnsChanged();
}

void DynamicTableModel::clearColumns()
{
    if (m_displayRoles.isEmpty()) return;

    beginResetModel();
    m_displayRoles.clear();
    endResetModel();

    emit columnsChanged();
}

void DynamicTableModel::setColumns(const QStringList &displayRoles)
{
    beginResetModel();
    m_displayRoles = displayRoles;
    endResetModel();

    emit columnsChanged();
}

QStringList DynamicTableModel::columns() const
{
    return m_displayRoles;
}

void DynamicTableModel::addRow(const QVariantMap &row)
{
    insertRow(m_rows.size(), row);
}

void DynamicTableModel::insertRow(int index, const QVariantMap &row)
{
    if (index < 0 || index > m_rows.size()) {
        qWarning() << "Invalid row index:" << index;
        return;
    }

    beginInsertRows(QModelIndex(), index, index);
    m_rows.insert(index, row);
    endInsertRows();

    emit rowsChanged();
}

void DynamicTableModel::removeRow(int index)
{
    if (index < 0 || index >= m_rows.size()) {
        qWarning() << "Invalid row index:" << index;
        return;
    }

    beginRemoveRows(QModelIndex(), index, index);
    m_rows.removeAt(index);
    endRemoveRows();

    emit rowsChanged();
}

void DynamicTableModel::clearRows()
{
    if (m_rows.isEmpty()) return;

    beginResetModel();
    m_rows.clear();
    endResetModel();

    emit rowsChanged();
}

QVariantMap DynamicTableModel::getRow(int index) const
{
    if (index < 0 || index >= m_rows.size()) {
        return QVariantMap();
    }
    return m_rows.at(index).toMap();
}

int DynamicTableModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_rows.size();
}

int DynamicTableModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_displayRoles.size();
}

// 关键修改：data() 方法
QVariant DynamicTableModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_rows.size() || index.column() >= m_displayRoles.size()) {
        return QVariant();
    }

    const QVariantMap row = m_rows.at(index.row()).toMap();
    const QString &roleName = m_displayRoles.at(index.column());

    // 关键：同时支持 Qt::DisplayRole 和 Qt::UserRole + 1（display）
    if (role == Qt::DisplayRole || role == Qt::UserRole + 1) {
        return row.value(roleName);
    }

    return QVariant();
}

bool DynamicTableModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || index.row() >= m_rows.size() || index.column() >= m_displayRoles.size()) {
        return false;
    }

    const QString &roleName = m_displayRoles.at(index.column());
    QVariantMap row = m_rows.at(index.row()).toMap();

    if (row.value(roleName) != value) {
        row[roleName] = value;
        m_rows[index.row()] = row;
        emit dataChanged(index, index, {role, Qt::DisplayRole});
        emit rowsChanged();
        return true;
    }
    return false;
}

QVariant DynamicTableModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (orientation == Qt::Horizontal && role == Qt::DisplayRole) {
        if (section >= 0 && section < m_displayRoles.size()) {
            QString title = m_displayRoles.at(section);
            // 首字母大写
            if (!title.isEmpty()) {
                title[0] = title[0].toUpper();
            }
            return title;
        }
    }
    return QAbstractTableModel::headerData(section, orientation, role);
}

// 关键修改：roleNames() 返回固定的 "display"
QHash<int, QByteArray> DynamicTableModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    // 固定使用 "display" 作为角色名，与原生 TableModel 一致
    roles[Qt::UserRole + 1] = QByteArrayLiteral("display");
    return roles;
}

Qt::ItemFlags DynamicTableModel::flags(const QModelIndex &index) const
{
    if (!index.isValid()) return Qt::NoItemFlags;
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsEditable;
}

QVariantList DynamicTableModel::rows() const
{
    return m_rows;
}

void DynamicTableModel::setRows(const QVariantList &rows)
{
    beginResetModel();
    m_rows = rows;
    endResetModel();
    emit rowsChanged();
}