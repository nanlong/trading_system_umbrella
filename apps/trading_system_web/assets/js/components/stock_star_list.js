import React from 'react'
import { gql, graphql } from 'react-apollo'
import { Table } from 'antd'


class StockStarList extends React.Component {

  onRowClick(record, index, event) {
    window.open(`/stocks/${record.symbol}`)
  }

  render() {
    const dataSource = this.props.data.stockStar
    const columns = [
      {title: '股票代码', dataIndex: 'symbol', key: 'symbol'},
      {title: '公司名称', dataIndex: 'stock.cname', key: 'stock.cname'},
      {title: '行业', dataIndex: 'stock.category', key: 'stock.category', render: (text, record, index) => text ? text : '--'},
      {title: 'ATR', dataIndex: 'atr20', key: 'atr20'},
      {title: '20日最低', dataIndex: 'dcl20', key: 'dcl20', render: (text, record, index) => `$${text}`},
      {title: '20日最高', dataIndex: 'dcu20', key: 'dcu20', render: (text, record, index) => `$${text}`},
      {title: '60日最低', dataIndex: 'dcl60', key: 'dcl60', render: (text, record, index) => `$${text}`},
      {title: '60日最高', dataIndex: 'dcu60', key: 'dcu60', render: (text, record, index) => `$${text}`},
    ]

    return (
      <div>
        <h1>关注 {dataSource ? dataSource.length : 0} 个股票</h1>
        <Table dataSource={dataSource} columns={columns} rowKey="symbol" onRowClick={this.onRowClick} />
      </div>
    )
  }
}

const graphqlQuery = gql`
  query {
    stockStar {
      date
      symbol
      dcl20
      dcu20
      dcl60
      dcu60
      atr20
      stock {
        cname
        category
      }
    }
  }
`

export default graphql(graphqlQuery)(StockStarList)