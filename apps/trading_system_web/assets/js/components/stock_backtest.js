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
      source.account.push(Math.ceil((item.account + item.marketCap - 10000) / 10000 * 1000) / 1000)
    }

    return source
  }

  setChartOption(data) {
    return {
      grid: {
        top: '15%',
        left: '5%',
        right: '2%',
        bottom: '10%'
      },
      tooltip: {
        trigger: 'axis',
        position: function (pt) {
          return [pt[0], '10%'];
        }
      },
      legend: {
        data: ['累计收益率']
      },
      toolbox: {
        feature: {
          dataZoom: {
            yAxisIndex: 'none'
          },
          restore: {},
          saveAsImage: {}
        }
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

  dateDiff(date1, date2, type) {
    date1 = typeof date1 == 'string' ? new Date(date1) : date1;
    date1 = date1.getTime();
    date2 = typeof date2 == 'string' ? new Date(date2) : date2;
    date2 = date2.getTime();
    type = type || 'year';

    var diffValue = Math.abs(date2 - date1);

    var second = 1000,
      minute = second * 60,
      hour = minute * 60,
      day = hour * 24,
      month = day * 30,
      year = month * 12

    var timeType = {
      second: second,
      minute: minute,
      hour: hour,
      day: day,
      month: month,
      year: year
    }
    
    return Math.ceil(diffValue / timeType[type] * 100) / 100
  }

  yearYieldRate(data) {
    const years = this.dateDiff(data.xAxisData[0], data.xAxisData[data.xAxisData.length - 1])
    const yieldRate = data.account[data.account.length - 1]
    return Math.ceil(yieldRate / years * 10000) / 100
  }

  componentDidUpdate() {
    const data = this.dataHandler(this.props.data)
    const chart = echarts.init(this.refs.stockBacktest)
    const options = this.setChartOption(data)
    const years = this.dateDiff(data.xAxisData[0], data.xAxisData[data.xAxisData.length - 1])

    this.refs.yearYieldRate.innerText = this.yearYieldRate(data)

    chart.setOption(options)
  }

  render() {
    return (
      <div>
        <div>最近三年年化收益率: <span ref="yearYieldRate"></span>%</div>
        <div ref="stockBacktest" style={{width: '100%', height: '220px'}}></div>
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