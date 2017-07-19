import React from 'react'
import { gql, graphql } from 'react-apollo'


class StockRelatime extends React.Component {

  componentDidUpdate({data: {refetch}}, state) {
    setTimeout(() => refetch(), 1000)
  }

  currency(value) {
    const newValue = parseFloat(value).toFixed(2)
    return isNaN(newValue) ? 0 : newValue
  }

  aHundredMillion(value) {
    const newValue = (parseFloat(value) / 100000000).toFixed(2)
    return isNaN(newValue) ? 0 : newValue + '亿'
  }

  pn(value) {
    const newValue = parseFloat(value) 
    return newValue > 0 ? '+' + newValue : newValue
  }

  dataHandler(data) {
    let newData = {
      price: this.currency(data.price),
      chg: this.currency(data.chg),
      open: this.currency(data.open),
      preClose: this.currency(data.preClose),
      highest: this.currency(data.highest),
      lowest: this.currency(data.lowest),
      w52Highest: this.currency(data.w52Highest),
      w52Lowest: this.currency(data.w52Lowest),
      marketCap: this.aHundredMillion(data.marketCap),
      capital: this.aHundredMillion(data.capital),
      chg: this.pn(data.chg),
      diff: this.pn(data.diff)
    }
    
    return Object.assign({}, data, newData)
  }

  render() {
    const data = this.dataHandler(this.props.data.stockRealtime ? this.props.data.stockRealtime[0] : {})
    
    return (
      <div>
        <div className="columns">
          <div className="column">
            <span style={{fontSize: '20px', marginRight: '10px'}}>{data.price}</span>
            <span>{data.chg}</span>
            <span>({data.diff}%)</span>
          </div>
        </div>
        <div className="columns">
          <div className="column is-6">
            <h5>详细行情</h5>
            <div className="columns">
              <div className="column is-6">
                <table className="table">
                  <tbody>
                    <tr>
                      <th>开盘：</th>
                      <td>{data.open}</td>
                    </tr>
                    <tr>
                      <th>成交：</th>
                      <td>{data.volume}</td>
                    </tr>
                    <tr>
                      <th>10日均量：</th>
                      <td>{data.volumeD10Avg}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <div className="column is-6">
                <table className="table">
                  <tbody>
                    <tr>
                      <th>前收盘：</th>
                      <td>{data.preClose}</td>
                    </tr>
                    <tr>
                      <th>区间：</th>
                      <td>{data.lowest}-{data.highest}</td>
                    </tr>
                    <tr>
                      <th>52周区间：</th>
                      <td>{data.w52Lowest}-{data.w52Highest}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
          <div className="column is-6">
            <h5>基本面摘要</h5>
            <div className="columns">
              <div className="column is-6">
                <table className="table">
                  <tbody>
                    <tr>
                      <th>市盈率：</th>
                      <td>{data.pe}</td>
                    </tr>
                    <tr>
                      <th>每股收益：</th>
                      <td>{data.eps}</td>
                    </tr>
                    <tr>
                      <th>贝塔系数：</th>
                      <td>{data.beta}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <div className="column is-6">
                <table className="table">
                  <tbody>
                    <tr>
                      <th>市值：</th>
                      <td>{data.marketCap}</td>
                    </tr>
                    <tr>
                      <th>股本：</th>
                      <td>{data.capital}</td>
                    </tr>
                    <tr>
                      <th>股息/收益率：</th>
                      <td>{data.dividend}/{data.yield}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

const graphqlQuery = gql`
  query StockRealtime($symbol: String!){
    stockRealtime(stocks: $symbol) {
      symbol
      price
      chg
      diff
      open
      volume
      volumeD10Avg
      preClose
      highest
      lowest
      w52Highest
      w52Lowest
      pe
      eps
      beta
      marketCap
      capital
      dividend
      yield
      random
    }
  }
`

const graphqlOptions = {
  options: {
    fetchPolicy: 'network-only',
    variables: {symbol: CONFIG['symbol']}
  }
}

export default graphql(graphqlQuery, graphqlOptions)(StockRelatime)