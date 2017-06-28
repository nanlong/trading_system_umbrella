import echarts from "echarts"

function data_handler(data) {
  let stocks = data.stocks.slice(data.stocks.length - data.dc60.length)
  let dc20 = data.dc20.slice(data.dc20.length - data.dc60.length)
  return {
    category: Array.from(data.dc60, (x) => x.date),
    values: Array.from(stocks, (x) => [x.openPrice, x.closePrice, x.lowestPrice, x.highestPrice]),
    dc60Max: Array.from(data.dc60, (x) => x.maxPrice),
    dc20Min: Array.from(dc20, (x) => x.minPrice),
  }
}

function chart(element_id, data) {
  const my_chart = echarts.init(document.getElementById(element_id))
  const my_data = data_handler(data)

  my_chart.setOption({
    title: {
      text: '唐奇安通道',
      top: 20,
      left: 'center'
    },
    legend: {
      bottom: 0,
      left: 'center',
      data: ['日K', 'DC 60 Max', 'DC 20 Min']
    },
    tooltip: {
      trigger: 'axis'
    },
    xAxis: {
      type: 'category',
      data: my_data.category
    },
    yAxis: {
      scale: true,
      splitArea: {
          show: true
      }
    },
    grid: {
      height: '60%'
    },
    dataZoom: [
      {
          type: 'inside',
          start: 90,
          end: 100
      },
      {
          show: true,
          type: 'slider',
          top: '85%',
          start: 90,
          end: 100
      }
    ],
    series: [
      {
        name: "日K",
        type: "candlestick",
        data: my_data.values
      },      
      {
       name: "DC 60 Max",
       type: 'line',
       data: my_data.dc60Max
      },
      {
        name: "DC 20 Min",
        type: 'line',
        data: my_data.dc20Min
      },
    ]
  })
}

export default chart

