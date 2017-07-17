import React from 'react'
import { gql, graphql } from 'react-apollo'
import { Table } from 'antd'

class StockStateList extends React.Component {

  componentDidUpdate({data: {refetch}}, state) {
    setTimeout(() => refetch(), 1000)
  }

  diff(a) {
    return a.price < a.dcu60 ? -(1 - a.price / a.dcu60) : a.price / a.dcu60 - 1
  }

  round(value, precision) {
    const multiplier = Math.pow(10, precision || 0);
    return Math.round(value * multiplier) / multiplier;
  }

  onRowClick(record, index, event) {
    window.open(`/stocks/${record.symbol}`)
  }

  render() {
    const dataSource = this.props.data.stockState
    const columns = [
      {title: '股票代码', dataIndex: 'symbol', key: 'symbol'},
      {title: '公司名称', dataIndex: 'stock.cname', key: 'stock.cname'},
      {title: '行业', dataIndex: 'stock.category', key: 'stock.category', render: (text, record, index) => text ? text : '--'},
      {title: 'ATR', dataIndex: 'atr20', key: 'atr20'},
      {title: '20日最低', dataIndex: 'dcl20', key: 'dcl20', render: (text, record, index) => `$${text}`},
      {title: '20日最高', dataIndex: 'dcu20', key: 'dcu20', render: (text, record, index) => `$${text}`},
      {title: '60日最低', dataIndex: 'dcl60', key: 'dcl60', render: (text, record, index) => `$${text}`},
      {title: '60日最高', dataIndex: 'dcu60', key: 'dcu60', render: (text, record, index) => `$${text}`},
      {title: '实时', dataIndex: 'price', key: 'price', 
      sorter: (a, b) => this.diff(b) - this.diff(a), sortOrder: 'ascend', render: (text, record, index) => `$${this.round(text, 2)}`},
    ]

    return (
      <div>
        <h1>{dataSource ? dataSource.length : 0} 个符合条件的股票</h1>
        <Table dataSource={dataSource} columns={columns} rowKey="symbol" onRowClick={this.onRowClick} />
      </div>
    )
  }
}

const graphql_query = gql`
  query {
    stockState {
      date
      symbol
      dcl20
      dcu20
      dcl60
      dcu60
      atr20
      price
      stock {
        cname
        category
      }
      random
    }
  }
`
const graphql_options = {
  options: {
    fetchPolicy: 'network-only'
  }
}

export default graphql(graphql_query, graphql_options)(StockStateList);