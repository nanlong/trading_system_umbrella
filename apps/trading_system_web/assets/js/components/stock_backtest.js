import React from 'react'
import { gql, graphql } from 'react-apollo'
import echarts from 'echarts'

class StockBacktest extends React.Component {

  dataHandler(data) {
    let source = {
      xAxisData: [],
      position: [],
      account: [],
    }

    for (let i = 0; i < data.stockBacktest.length; i++) {
      let item = data.stockBacktest[i]
      source.xAxisData.push(item.date)
      source.position.push(item.position * item.unit)
      source.account.push(((item.account + item.marketCap) - 10000) / 10000 )
    }
    console.log(source)

    return source
  }

  setChartOption(data) {
    return {
      legend: {
        data: ['累计收益率']
      },
      xAxis: {
        type: 'category',
        data: data.xAxisData
      },
      yAxis: {
        type: 'value'
      },
      series: [
        {
          name: '累计收益率',
          type: 'line',
          stack: 'one',
          data: data.account,
          barGap: '-100%'
        }
      ]
    }
  }

  componentDidUpdate() {
    const data = this.dataHandler(this.props.data)
    const chart = echarts.init(this.refs.stockPosition)
    const options = this.setChartOption(data)
    chart.setOption(options)
  }

  render() {
    return (
      <div className="columns">
        <div className="column">
          <div ref="stockPosition" style={{width: '100%', height: '500px'}}></div>
        </div>

      </div>
    )
  }
}

const graphqlQuery = gql`
  query Backtest($symbol: String) {
    stockBacktest(symbol: $symbol) {
      date
			initAccount
    	account
    	action
    	price
    	unit
      position
      marketCap
    }
  }
`

const graphqlOptions = {
  options: {
    variables: {symbol: CONFIG['symbol']}
  }
}

export default graphql(graphqlQuery, graphqlOptions)(StockBacktest)