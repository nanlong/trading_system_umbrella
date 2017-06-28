import "phoenix_html"
import ApolloClient, { createNetworkInterface } from "apollo-client"
import gql from "graphql-tag"
import chart from "./chart"

const client = new ApolloClient({
  networkInterface: createNetworkInterface({
    uri: "/api",
  }),
});

function render_chart(symbol, duration) {
  client.query({
    query: gql`
      query {
        usStocks(symbol: "${symbol}") {
          date
          openPrice
          closePrice
          lowestPrice
          highestPrice
          turnoverVol
        }
        donchianChannel(symbol: "${symbol}", duration: ${duration}) {
          date
          maxPrice
          midPrice
          minPrice
        }
      }
    `
  })
  .then(resp => chart('chart', resp.data))
  .catch(error => console.error(error))
}

render_chart(CONFIG['symbol'], 60)


