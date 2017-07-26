import React from 'react'
import { ApolloClient, createNetworkInterface, ApolloProvider } from 'react-apollo'
import ReactDOM from 'react-dom';
import StockStateList from './components/stock_state_list'
import StockRealtime from './components/stock_realtime'
import StockChart from './components/stock_chart'
import StockBacklistBtn from './components/stock_backlist_btn'
import StockStarBtn from './components/stock_star_btn'


const client = new ApolloClient({
  networkInterface: createNetworkInterface({
    uri: '/api',
  }),
})


if (document.getElementById('usstock-state-list')) {
  ReactDOM.render(
    <ApolloProvider client={client}>
      <StockStateList />
    </ApolloProvider>,
    document.getElementById('usstock-state-list'),
  )
}

if (document.getElementById('stock-realtime')) {
  ReactDOM.render(
    <ApolloProvider client={client}>
      <StockRealtime />
    </ApolloProvider>,
    document.getElementById('stock-realtime'),
  )
}

if (document.getElementById('stock-chart')) {
  ReactDOM.render(
    <ApolloProvider client={client}>
      <StockChart />
    </ApolloProvider>,
    document.getElementById('stock-chart'),
  )
}

if (document.getElementById('stock-backlist-btn')) {
  ReactDOM.render(
    <StockBacklistBtn symbol={CONFIG['symbol']} isBlacklist={CONFIG['isBlacklist']}/>,
    document.getElementById('stock-backlist-btn'),
  )
}

if (document.getElementById('stock-star-btn')) {
  ReactDOM.render(
    <StockStarBtn symbol={CONFIG['symbol']} isStar={CONFIG['isStar']}/>,
    document.getElementById('stock-star-btn'),
  )
}
