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
      dcu10Data: [],
      dcu20Data: [],
      dcu60Data: [],
      dcl10Data: [],
      dcl20Data: [],
      dcl60Data: [],
      atrData: [],
      pointData: [],
      createPointData: [],
      closePointData: [],
    }

    let lineData = []

    for (let i = 0; i < data.stockDailykLine.length; i++) {
      if (! data.stockDailykLine[i] || ! data.stockStateLine[i]) { break }

      const {date, open, close, highest, lowest} = data.stockDailykLine[i]
      const {ma5, ma10, ma20, ma30, ma50, ma300, dcu10, dcu20, dcu60, dcl10, dcl20, dcl60, atr20} = data.stockStateLine[i]

      lineData.push({
        date: date,
        open: open,
        close: close,
        highest: highest,
        lowest: lowest,
        atr: atr20,
        ma5: ma5,
        ma10: ma10,
        ma20: ma20,
        ma30: ma30,
        ma50: ma50,
        ma300: ma300,
        dcu10: dcu10,
        dcu20: dcu20,
        dcu60: dcu60,
        dcl10: dcl10,
        dcl20: dcl20,
        dcl60: dcl60,
      })
    }

    data.stockBacktest.map((x) => {
      const {date, tread, action, price} = x

      if (CONFIG["tread"] == tread) {
        switch(action) {
          case "create":
            source.createPointData.push(this.markPoint(date, price, '#34a853'))
            break
          case "close":
            source.closePointData.push(this.markPoint(date, price, '#fbbc05'))
            break
          case "stop":
            source.closePointData.push(this.markPoint(date, price, '#9966CC'))
            break
        }
      }
    })

    lineData.map(x => {
      const {date, open, close, highest, lowest, ma5, ma10, ma20, ma30, ma50, ma300, dcu10, dcu20, dcu60, dcl10, dcl20, dcl60, atr} = x
      source.categoryData.push(date)
      source.dailykData.push([open, close, lowest, highest])
      source.ma5Data.push(ma5)
      source.ma10Data.push(ma10)
      source.ma20Data.push(ma20)
      source.ma30Data.push(ma30)
      source.ma50Data.push(ma50)
      source.ma300Data.push(ma300)
      source.dcu10Data.push(dcu10)
      source.dcu20Data.push(dcu20)
      source.dcu60Data.push(dcu60)
      source.dcl10Data.push(dcl10)
      source.dcl20Data.push(dcl20)
      source.dcl60Data.push(dcl60)
      source.atrData.push(atr)
    })

    return source
  }

  setChartOption(data) {
    let series = [
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
          name: 'ATR',
          type: 'line',
          data: data.atrData,
          xAxisIndex: 1,
          yAxisIndex: 1,
        }
      ]

    let legendData = ['日K', 'MA5', 'MA10', 'MA20', 'MA30']
    let legendSelected = {}

    if (CONFIG["isVip"] == true) {
      let seriesLine = []
      let upName = CONFIG['userConfig'].create_days + '日' + (CONFIG["tread"] == 'bull' ? '最高' : '最低')
      let upData = data['dc' + (CONFIG["tread"] == 'bull' ? 'u' : 'l') + CONFIG['userConfig'].create_days + 'Data']
      let lowName = CONFIG['userConfig'].close_days + '日' + (CONFIG["tread"] == 'bull' ? '最低' : '最高')
      let lowData = data['dc' + (CONFIG["tread"] == 'bull' ? 'l' : 'u') + CONFIG['userConfig'].close_days + 'Data']
      
      legendData.push(upName)
      legendData.push(lowName)
      seriesLine.push({name: upName, data: upData, color: '#014EA2', point: data.createPointData})
      seriesLine.push({name: lowName, data: lowData, color: '#014EA2', point: data.closePointData})
      
      if (CONFIG['userConfig'].create_days == 20) {
        let secondUpName = '60日最' + (CONFIG["tread"] == 'bull' ? '高' : '低')
        let secondUpData = data['dc' + (CONFIG["tread"] == 'bull' ? 'u' : 'l') + '60Data']
        let secondLowName = '20日最' + (CONFIG["tread"] == 'bull' ? '低' : '高')
        let secondLowData = data['dc' + (CONFIG["tread"] == 'bull' ? 'l' : 'u') + '20Data']
        
        legendData.push(secondUpName)
        legendData.push(secondLowName)
        seriesLine.push({name: secondUpName, data: secondUpData, color: '#014EA2'})
        seriesLine.push({name: secondLowName, data: secondLowData, color: '#014EA2'})
        legendSelected[secondUpName] = false
        legendSelected[secondLowName] = false
      }
  
      seriesLine.map(x => {
        const {name, data, color} = x
        series.push({
          name: name,
          type: 'line',
          data: data,
          smooth: true,
          showSymbol: false,
          lineStyle: {
            normal: {
              color: color,
              width: 1
            }
          },
          itemStyle: {
            normal: {
              color: color
            }
          },
          markPoint: {
            data: x.point || []
          }
        })
      })
    }
    
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
        data: legendData,
        selected: legendSelected
      },
      grid: [
        {
          top: '8%',
          left: '4%',
          right: '1%',
          bottom: '25%'
        },
        {
          left: '4%',
          right: '1%',
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
      series: series
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
      dcu10
      dcu20
      dcu60
      dcl10
      dcl20
      dcl60
      atr20
    }
    stockBacktest(symbol: $symbol) {
      date
      tread
      action
      price
    }
  }
`

const graphqlOptions = {
  options: {
    variables: {symbol: CONFIG['symbol']}
  }
}

export default graphql(graphqlQuery, graphqlOptions)(StockChart)