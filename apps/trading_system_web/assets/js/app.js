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
      query Stocks($symbol: String) {
        stocks: usStocks(symbol: $symbol) {
          date
          openPrice
          closePrice
          lowestPrice
          highestPrice
          turnoverVol
        }
        dc20: donchianChannel(symbol: $symbol, duration: 20) {
          ...dc
        }
        dc60: donchianChannel(symbol: $symbol, duration: 60) {
          ...dc
        }
      }

      fragment dc on DonchianChannel {
        date
        high
        avg
        low
      }
    `,
    variables: {
      symbol: symbol
    }
  })
  .then(resp => chart('chart', resp.data))
  .catch(error => console.error(error))
}

render_chart(CONFIG['symbol'], 60)


