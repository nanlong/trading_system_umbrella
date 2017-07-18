import React from 'react'
import { gql, graphql } from 'react-apollo'
import echarts from 'echarts'


class StockChart extends React.Component {

  dataHandler(data) {
    let source = {
      categoryData: [],
      dailykData: [],
      ma5Data: [],
      ma10Data: [],
      ma20Data: [],
      ma30Data: [],
      dcu60Data: [],
      dcl20Data: []
    }
    
    for (let i = 0; i < data.stockDailykLine.length; i++) {
      const {date, open, close, highest, lowest} = data.stockDailykLine[i]
      const {ma5, ma10, ma20, ma30, dcu60, dcl20} = data.stockStateLine[i]
      source.categoryData.push(date)
      source.dailykData.push([open, close, lowest, highest])
      source.ma5Data.push(ma5)
      source.ma10Data.push(ma10)
      source.ma20Data.push(ma20)
      source.ma30Data.push(ma30)
      source.dcu60Data.push(dcu60)
      source.dcl20Data.push(dcl20)
    }

    return source
  }

  setChartOption(data) {
    return {
      tooltip: {
        trigger: 'axis',
        axisPointer: {
            type: 'cross'
        }
      },
      legend: {
        data: ['日K', 'MA5', 'MA10', 'MA20', 'MA30', '60日最高', '20日最低']
      },
      grid: {
        top: '8%',
        left: '5%',
        right: '5%',
        bottom: '18%'
      },
      xAxis: {
        type: 'category',
        data: data.categoryData,
        axisLine: { lineStyle: { color: '#8392A5' } }
      },
      yAxis: {
        scale: true,
        splitArea: {
            show: true
        }
      },
      dataZoom: {
        start: (1 - 80 / data.categoryData.length) * 100,
        end: 100
      },
      series: [
        {
          name: '日K',
          type: 'candlestick',
          data: data.dailykData,
        },
        {
          name: 'MA5',
          type: 'line',
          data: data.ma5Data,
          smooth: true,
          showSymbol: false,
          lineStyle: {
            normal: {
              width: 1
            }
          }
        },
        {
          name: 'MA10',
          type: 'line',
          data: data.ma10Data,
          smooth: true,
          showSymbol: false,
          lineStyle: {
            normal: {
              width: 1
            }
          }
        },
        {
          name: 'MA20',
          type: 'line',
          data: data.ma20Data,
          smooth: true,
          showSymbol: false,
          lineStyle: {
            normal: {
              width: 1
            }
          }
        },
        {
          name: 'MA30',
          type: 'line',
          data: data.ma30Data,
          smooth: true,
          showSymbol: false,
          lineStyle: {
            normal: {
              width: 1
            }
          }
        },
        {
          name: '60日最高',
          type: 'line',
          data: data.dcu60Data,
          smooth: true,
          showSymbol: false,
          lineStyle: {
            normal: {
              width: 1
            }
          }
        },
        {
          name: '20日最低',
          type: 'line',
          data: data.dcl20Data,
          smooth: true,
          showSymbol: false,
          lineStyle: {
            normal: {
              width: 1
            }
          }
        },
      ]
    }
  }

  componentDidUpdate() {
    const data = this.dataHandler(this.props.data)
    const chart = echarts.init(this.refs.stockChart)
    const options = this.setChartOption(data)
    chart.setOption(options)
  }

  render() {
    return(
      <div ref="stockChart" style={{width: '100%', height: '400px'}}></div>
    )
  }
}

const graphql_query = gql`
  query StockChart($symbol: String!){
    stockDailykLine(symbol: $symbol) {
      date
      open
      close
      highest
      lowest
      preClose
      volume
    }
    stockStateLine(symbol: $symbol) {
      date
      ma5
      ma10
      ma20
      ma30
      dcu60
      dcl20
    }
  }
`

const graphql_options = {
  options: {
    variables: {symbol: CONFIG['symbol']}
  }
}

export default graphql(graphql_query, graphql_options)(StockChart)