import echarts from "echarts"

function data_handler(data) {
  let stocks = data.usStocks.slice(data.usStocks.length - data.donchianChannel.length)

  return {
    category: Array.from(data.donchianChannel, (x) => x.date),
    values: Array.from(stocks, (x) => [x.openPrice, x.closePrice, x.lowestPrice, x.highestPrice]),
    donchianChannelMax20: Array.from(data.donchianChannel, (x) => x.maxPrice),
    donchianChannelMin20: Array.from(data.donchianChannel, (x) => x.minPrice)
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
      bottom: 10,
      left: 'center',
      data: ['日K', 'DC Max 20', 'DC Min 20']
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
      height: '70%'
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
          top: '88%',
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
       name: "DC Max 20",
       type: 'line',
       data: my_data.donchianChannelMax20
      },
      {
        name: "DC Min 20",
        type: 'line',
        data: my_data.donchianChannelMin20
      }
    ]
  })
}

export default chart

