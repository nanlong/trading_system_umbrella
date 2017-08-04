import React from 'react'
import { gql } from 'react-apollo'
import { Button } from 'antd'
import client from '../lib/apollo_client'


class StockBacklistBtn extends React.Component {

  constructor(props) {
    super(props)
    const {symbol, isBlacklist} = this.props
    this.createBacklist = this.createBacklist.bind(this)
    this.deleteBacklist = this.deleteBacklist.bind(this)

    this.client = client

    this.state = {
      symbol: symbol,
      isBlacklist: isBlacklist
    }
  }

  createBacklist() {
    const {symbol, isBlacklist} = this.state

    this.client.mutate({
      mutation: gql`
        mutation createBacklist($symbol: String!) {
          createStockBacklist(symbol: $symbol) {
            symbol
          }
        }
      `,
      variables: {symbol: symbol}
    })
    .then(resp => this.setState({isBlacklist: !isBlacklist}))
  }

  deleteBacklist() {
    const {symbol, isBlacklist} = this.state
    
    this.client.mutate({
      mutation: gql`
        mutation deleteBacklist($symbol: String!) {
          deleteStockBacklist(symbol: $symbol) {
            symbol
          }
        }
      `,
      variables: {symbol: symbol}
    })
    .then(resp => this.setState({isBlacklist: !isBlacklist}))
    .catch(error => console.log(error))
  }

  render() {
    return this.state.isBlacklist ? 
      (<Button onClick={this.deleteBacklist}>取消黑名单</Button>) : 
      (<Button onClick={this.createBacklist}>加入黑名单</Button>)
  }
}

export default StockBacklistBtn