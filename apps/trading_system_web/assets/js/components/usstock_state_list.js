import React from 'react'
import { gql, graphql } from 'react-apollo'
import { Table } from 'antd'

class USStockStateList extends React.Component {

  componentDidUpdate({data: {refetch}}, state) {
    console.log('refetch')
    setTimeout(() => refetch(), 1000)
  }

  diff(a) {
    if (a.price < a.highD60) {
      return -(1 - a.price / a.highD60)
    }
    else {
      return a.price / a.highD60 - 1
    }
  }

  render() {
    const columns = [
      {title: '股票代码', dataIndex: 'symbol', key: 'symbol'},
      {title: '公司名称', dataIndex: 'stock.cname', key: 'stock.cname'},
      {title: '行业', dataIndex: 'stock.category', key: 'stock.category'},
      {title: '20日最低', dataIndex: 'lowD20', key: 'lowD20'},
      {title: '60日最高', dataIndex: 'highD60', key: 'highD60'},
      {title: '实时', dataIndex: 'price', key: 'price', 
      sorter: (a, b) => this.diff(b) - this.diff(a), sortOrder: 'ascend'},
    ]

    return (
      <Table dataSource={this.props.data.usstockState} columns={columns} rowKey="symbol" />
    )
  }
}


const graphql_query = gql`
  query {
    usstockState {
      date
      symbol
      highD60
      highD20
      lowD20
      lowD10
      n
      nRatioD60
      nRatioD20
      avgD50GtD300
      price
      random
      stock {
        cname
        category
      }
    }
  }
`
const graphql_options = {
  options: {
    fetchPolicy: 'network-only'
  }
}

export default graphql(graphql_query, graphql_options)(USStockStateList);