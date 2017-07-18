import React from 'react'
import { gql, graphql } from 'react-apollo'
import createG2 from 'g2-react'
import { Stat, Frame, Chart } from 'g2'
import Slider from 'g2-plugin-slider'

function get_date_range(data) {
  let data_length = data.length
  let end_item = data[data_length - 1]
  let start_item = data[data_length - 80 * 6]

  return {
    start: start_item ? start_item.date : '',
    end: end_item ? end_item.date : ''
  }
}

const LineChart = createG2(chart => {
  chart.axis('value', false);
  chart.legend({
        position: 'top'
      });
      chart.tooltip({
        crosshairs: true
      });
  chart.col('date', {
    type: 'timeCat',
    nice: false,
    mask: 'yy-mm-dd',
    alias: '时间',
    tickCount: 10
  })
  chart.col('volume', {alias: '成交量'})
  chart.col('open', {alias: '开盘价'})
  chart.col('close', {alias: '收盘价'})
  chart.col('highest', {alias: '最高价'})
  chart.col('lowest', {alias: '最低价'})
  chart.col('preClose', {alias: '昨收盘'})
  chart.col('open+close+highest+lowest+preClose', {alias: '股票价格'})
  chart.axis('date', {
    title: null
  })
  chart.schema()
    .position('date*(open+close+highest+lowest+preClose)')
    .color('trend', ['#2AF483','#F80041'])
    .shape('candle')
    .tooltip('preClose*open*close*highest*lowest*volume')

  chart.line().position('date*value').color('type', ['#AC4640', '#2D3C48', '#609099', '#BE7459', '#f00', '#000'])

  const data = chart.get('data').toJSON()
  const {start, end} = get_date_range(data)
  
  const slider = new Slider({
    domId: 'slider',
    height: 20,
    charts: [chart],
    xDim: 'date',
    yDim: 'highest',
    start: start,
    end: end
  })

  slider.render()
})

class StockChart extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      width: 760,
      height: 400,
      plotCfg: {margin: [60, 20, 30, 80]}
    }
  }

  dataHandler(data) {
    let line_data = data.stockDailykLine ? data.stockDailykLine : []    
    let state_data = data.stockStateLine ? data.stockStateLine : []
    let source = []

    for (let i = 0; i < line_data.length; i++) {
      if (!! state_data[i]) {
        let line = line_data[i]
        let state = state_data[i]
        let item = {
          date: line.date,
          open: line.open,
          close: line.close,
          highest: line.highest,
          lowest: line.lowest,
          preClose: line.preClose,
          volume: line.volume,
          trend: line.open <= line.close ? 'down' : 'up',
          ma5: state.ma5,
          ma10: state.ma10,
          ma20: state.ma20,
          ma30: state.ma30,
          dcu60: state.dcu60,
          dcl20: state.dcl20
        }
        source.push(item)
      }
    }

    let frame = new Frame(source)
    frame = Frame.combinColumns(frame, ['ma5','ma10','ma20','ma30', 'dcu60', 'dcl20'], 'value', 'type')
    return frame
  }

  render() {
    let data = this.dataHandler(this.props.data)

    if (data instanceof Frame) {
      data = data.toJSON()
    }

    if (data.length === 0) {
      return (<div></div>)
    }
    else {
      return (
          <LineChart 
            data={data}
            width={this.state.width}
            height={this.state.height}
            plotCfg={this.state.plotCfg}
            ref="stockChart" 
          />
      )
    }
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