import React from 'react'
import { ApolloClient, createNetworkInterface, ApolloProvider } from 'react-apollo'
import ReactDOM from 'react-dom';
import StockStateList from './components/stock_state_list'
import StockRealtime from './components/stock_realtime'


const client = new ApolloClient({
  networkInterface: createNetworkInterface({
    uri: '/api',
  }),
})


if (document.getElementById('usstock-state-list')) {
  ReactDOM.render(
    <ApolloProvider client={client}>
      <StockStateList/>
    </ApolloProvider>,
    document.getElementById('usstock-state-list'),
  )
}

if (document.getElementById('stock-realtime')) {
  ReactDOM.render(
    <ApolloProvider client={client}>
      <StockRealtime/>
    </ApolloProvider>,
    document.getElementById('stock-realtime'),
  )
}
