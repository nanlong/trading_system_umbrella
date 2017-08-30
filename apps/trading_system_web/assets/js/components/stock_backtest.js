import React from 'react'
import { gql, graphql } from 'react-apollo'
import echarts from 'echarts'

class StockBacktest extends React.Component {

  dataHandler(data) {
    let source = {
      xAxisData: [],
      ratioData: []
    }
    
    data.stockBacktest.map(x => {
      const {date, ratio} = x
      source.xAxisData.push(date)
      source.ratioData.push(ratio)
    })

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
          data: data.ratioData,
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
    const yieldRate = data.ratioData[data.ratioData.length - 1]
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
        <div>
          <strong className="is-size-5">最近3年年化收益率: <span ref="yearYieldRate"></span>%</strong>
          (收益率计算过程中包括做空和做多)
        </div>
        <div ref="stockBacktest" style={{width: '100%', height: '220px'}}></div>
      </div>
    )
  }
}

const graphqlQuery = gql`
  query Backtest($symbol: String) {
    stockBacktest(symbol: $symbol) {
      date
			ratio
    }
  }
`

const graphqlOptions = {
  options: {
    variables: {symbol: CONFIG['symbol']}
  }
}

export default graphql(graphqlQuery, graphqlOptions)(StockBacktest)