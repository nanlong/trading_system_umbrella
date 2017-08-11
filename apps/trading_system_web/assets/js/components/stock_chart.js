import React from 'react'
import { gql, graphql } from 'react-apollo'
import echarts from 'echarts'
import { stop_loss } from '../lib/stock'


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
      ma50Data: [],
      ma300Data: [],
      dcu20Data: [],
      dcu60Data: [],
      dcl10Data: [],
      dcl20Data: [],
      dcu20Point: [],
      atrData: [],
      dcl10Point: [],
      dcu60Point: [],
      dcl20Point: [],
      line20Cache: [],
      line60Cache: [],
    }

    let p20State = {}
    let p60State = {}

    function is_pre_break_down(linePoint) {
      return linePoint.length == 0 
        || linePoint[linePoint.length - 1].itemStyle.normal.color == '#fbbc05'
        || linePoint[linePoint.length - 1].itemStyle.normal.color == '#9966CC'
    }

    function is_pre_break_up(linePoint) {
      return linePoint.length > 0 
        && linePoint[linePoint.length - 1].itemStyle.normal.color == '#34a853'
    }

    for (let i = 0; i < data.stockDailykLine.length; i++) {
      if (! data.stockDailykLine[i] || ! data.stockStateLine[i]) { break }
      const {date, open, close, highest, lowest} = data.stockDailykLine[i]
      const {ma5, ma10, ma20, ma30, ma50, ma300, dcu60, dcu20, dcl20, dcl10, atr20} = data.stockStateLine[i]
      source.categoryData.push(date)
      source.dailykData.push([open, close, lowest, highest])
      source.ma5Data.push(ma5)
      source.ma10Data.push(ma10)
      source.ma20Data.push(ma20)
      source.ma30Data.push(ma30)
      source.ma50Data.push(ma50)
      source.ma300Data.push(ma300)
      source.dcu60Data.push(dcu60)
      source.dcu20Data.push(dcu20)
      source.dcl20Data.push(dcl20)
      source.dcl10Data.push(dcl10)
      source.atrData.push(atr20)

      // 20日突破点
      if (highest > dcu20 && is_pre_break_down(source.line20Cache)) {
        let point = this.markPoint(date, dcu20, '#34a853')
        source.line20Cache.push(point)
        source.dcu20Point.push(point)

        p20State = {
          break: dcu20,
          next_break: dcu20 + atr20 * 0.5,
          atr: atr20,
          stop: stop_loss(dcu20, atr20, 1),
          count: 1
        }
      }
      // 20日突破后的加仓
      else if (is_pre_break_up(source.line20Cache) && highest > p20State.next_break && p20State.count < 4) {
        p20State = {
          break: p20State.break,
          next_break: p20State.next_break + p20State.atr * 0.5,
          atr: p20State.atr,
          stop: stop_loss(p20State.break, p20State.atr, p20State.count + 1),
          count: p20State.count + 1
        }
      }
      // 20日止损点
      else if(is_pre_break_up(source.line20Cache) && lowest < p20State.stop) {
        let point = this.markPoint(date, p20State.stop, '#9966CC')
        source.line20Cache.push(point)
        source.dcu20Point.push(point)
        p20State = {}
      }
      // 20日止盈点
      else if (lowest < dcl10 && is_pre_break_up(source.line20Cache)) {
        let point = this.markPoint(date, dcl10, '#fbbc05')
        source.line20Cache.push(point)
        source.dcl10Point.push(point)
      }

      // 60日突破点
      if (highest > dcu60 && is_pre_break_down(source.line60Cache)) {
        let point = this.markPoint(date, dcu60, '#34a853')
        source.line60Cache.push(point)
        source.dcu60Point.push(point)
      }
      // 60日止盈点
      else if (lowest < dcl20 && is_pre_break_up(source.line60Cache)) {
        let point = this.markPoint(date, dcl20, '#fbbc05')
        source.line60Cache.push(point)
        source.dcl20Point.push(point)
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
        },
        borderWidth: 1,
        borderColor: '#ccc',
        padding: 10,
        position: function (pos, params, el, elRect, size) {
          let obj = {top: 10}
          obj[['left', 'right'][+(pos[0] < size.viewSize[0] / 2)]] = 30
          return obj;
        },
        extraCssText: 'width: 170px'
      },
      axisPointer: {
        link: {xAxisIndex: 'all'},
        label: {
          backgroundColor: '#777'
        }
      },
      legend: {
        data: ['日K', 'MA5', 'MA10', 'MA20', 'MA30', '20日最高', '10日最低', '60日最高', '20日最低'],
        selected: {'60日最高': false, '20日最低': false}
      },
      grid: [
        {
          top: '8%',
          left: '5%',
          right: '5%',
          bottom: '25%'
        },
        {
          left: '5%',
          right: '5%',
          top: '82%',
          height: '8%'
        }
      ],
      xAxis: [
        {
          type: 'category',
          data: data.categoryData,
          axisLine: { lineStyle: { color: '#8392A5' } }
        },
        {
          gridIndex: 1,
          type: 'category',
          data: data.categoryData,
          show: false,
        }
      ],
      yAxis: [
        {
          scale: true,
          splitArea: {
            show: true
          }
        },
        {
          gridIndex: 1,
          type: 'value',
        }
      ],
      dataZoom: [
        {
          start: (1 - 120 / data.categoryData.length) * 100,
          end: 100,
          xAxisIndex: [0, 1]
        },
        {
          start: (1 - 120 / data.categoryData.length) * 100,
          end: 100,
          xAxisIndex: [0, 1]
        },
      ],
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
        {
          name: 'ATR',
          type: 'line',
          data: data.atrData,
          xAxisIndex: 1,
          yAxisIndex: 1,
        }
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
      ma50
      ma300
      dcu20
      dcu60
      dcl10
      dcl20
      atr20
    }
  }
`

const graphqlOptions = {
  options: {
    variables: {symbol: CONFIG['symbol']}
  }
}

export default graphql(graphqlQuery, graphqlOptions)(StockChart)