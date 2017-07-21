import React from 'react'
import { gql, graphql } from 'react-apollo'
import echarts from 'echarts'


class StockChart extends React.Component {

  markPoint(x, y, color) {
    return {
      coord: [x, y],
      symbol: 'circle',
      symbolSize: 8,
      itemStyle: {
        normal: {
          color: color
        }
      },
      label: {
        normal: {
          show: false
        }
      }
    }
  }

  dataHandler(data) {
    let source = {
      categoryData: [],
      dailykData: [],
      ma5Data: [],
      ma10Data: [],
      ma20Data: [],
      ma30Data: [],
      dcu60Data: [],
      dcl20Data: [],
      candlestickPoints: []
    }
    
    for (let i = 0; i < data.stockDailykLine.length; i++) {
      if (! data.stockDailykLine[i] || ! data.stockStateLine[i]) { break }
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

      if (highest > dcu60) {
        source.candlestickPoints.push(this.markPoint(date, dcu60, '#34a853'))
      }
      else if (lowest < dcl20) {
        source.candlestickPoints.push(this.markPoint(date, dcl20, '#fbbc05'))
      }
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
        data: ['日K', 'MA5', 'MA10', 'MA20', 'MA30', '60日最高', '20日最低'],
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
          markPoint: {
            data: data.candlestickPoints
          }
        },
        {
          name: 'MA5',
          type: 'line',
          data: data.ma5Data,
          smooth: true,
          showSymbol: false,
          lineStyle: {
            normal: {
              color: '#FC9CB8',
              width: 1
            }
          },
          itemStyle: {
            normal: {
              color: '#FC9CB8'
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
              color: '#12BDD9',
              width: 1
            }
          },
          itemStyle: {
            normal: {
              color: '#12BDD9'
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
              color: '#EE2F72',
              width: 1
            }
          },
          itemStyle: {
            normal: {
              color: '#EE2F72'
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
              color: '#8CBB0D',
              width: 1
            }
          },
          itemStyle: {
            normal: {
              color: '#8CBB0D'
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
              color: '#014EA2',
              width: 1
            }
          },
          itemStyle: {
            normal: {
              color: '#014EA2'
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
              color: '#014EA2',
              width: 1
            }
          },
          itemStyle: {
            normal: {
              color: '#014EA2'
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
      <div ref="stockChart" style={{width: '100%', height: '500px'}}></div>
    )
  }
}

const graphqlQuery = gql`
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

const graphqlOptions = {
  options: {
    variables: {symbol: CONFIG['symbol']}
  }
}

export default graphql(graphqlQuery, graphqlOptions)(StockChart)