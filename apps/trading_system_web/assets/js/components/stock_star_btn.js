import React from 'react'
import { gql } from 'react-apollo'
import { Button } from 'antd'
import client from '../lib/client'


class StockStarBtn extends React.Component {

  constructor(props) {
    super(props)
    const {symbol, isStar} = this.props
    this.createStar = this.createStar.bind(this)
    this.deleteStar = this.deleteStar.bind(this)

    this.client = client

    this.state = {
      symbol: symbol,
      isStar: isStar
    }
  }

  createStar() {
    const {symbol, isStar} = this.state

    this.client.mutate({
      mutation: gql`
        mutation createStar($symbol: String!) {
          createStockStar(symbol: $symbol) {
            symbol
          }
        }
      `,
      variables: {symbol: symbol}
    })
    .then(resp => this.setState({isStar: !isStar}))
  }

  deleteStar() {
    const {symbol, isStar} = this.state
    
    this.client.mutate({
      mutation: gql`
        mutation deleteStar($symbol: String!) {
          deleteStockStar(symbol: $symbol) {
            symbol
          }
        }
      `,
      variables: {symbol: symbol}
    })
    .then(resp => this.setState({isStar: !isStar}))
    .catch(error => console.log(error))
  }

  render() {
    return this.state.isStar ? 
      (<Button type="primary" onClick={this.deleteStar}>取消收藏</Button>) : 
      (<Button type="primary" onClick={this.createStar}>加入收藏</Button>)
  }
}

export default StockStarBtn