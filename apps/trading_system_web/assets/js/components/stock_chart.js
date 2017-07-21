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
      dcu20Data: [],
      dcu60Data: [],
      dcl10Data: [],
      dcl20Data: [],
      dcu20Point: [],
      dcl10Point: [],
      dcu60Point: [],
      dcl20Point: []
    }
    
    for (let i = 0; i < data.stockDailykLine.length; i++) {
      if (! data.stockDailykLine[i] || ! data.stockStateLine[i]) { break }
      const {date, open, close, highest, lowest} = data.stockDailykLine[i]
      const {ma5, ma10, ma20, ma30, dcu60, dcu20, dcl20, dcl10} = data.stockStateLine[i]
      source.categoryData.push(date)
      source.dailykData.push([open, close, lowest, highest])
      source.ma5Data.push(ma5)
      source.ma10Data.push(ma10)
      source.ma20Data.push(ma20)
      source.ma30Data.push(ma30)
      source.dcu60Data.push(dcu60)
      source.dcu20Data.push(dcu20)
      source.dcl20Data.push(dcl20)
      source.dcl10Data.push(dcl10)

      if (highest > dcu20) {
        source.dcu20Point.push(this.markPoint(date, dcu20, '#34a853'))
      }

      if (lowest < dcl10) {
        source.dcl10Point.push(this.markPoint(date, dcl10, '#fbbc05'))
      }

      if (highest > dcu60) {
        source.dcu60Point.push(this.markPoint(date, dcu60, '#34a853'))
      }
      
      if (lowest < dcl20) {
        source.dcl20Point.push(this.markPoint(date, dcl20, '#fbbc05'))
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
        data: ['日K', 'MA5', 'MA10', 'MA20', 'MA30', '20日最高', '10日最低', '60日最高', '20日最低'],
        selected: {'60日最高': false, '20日最低': false}
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
          data: data.dailykData
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
          name: '20日最高',
          type: 'line',
          data: data.dcu20Data,
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
          },
          markPoint: {
            data: data.dcu20Point
          }
        },
        {
          name: '10日最低',
          type: 'line',
          data: data.dcl10Data,
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
          },
          markPoint: {
            data: data.dcl10Point
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
          },
          markPoint: {
            data: data.dcu60Point
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
          },
          markPoint: {
            data: data.dcl20Point
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
      dcu20
      dcu60
      dcl10
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