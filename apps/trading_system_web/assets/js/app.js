import "phoenix_html"
import ApolloClient, { createNetworkInterface } from "apollo-client"
import gql from "graphql-tag"
import chart from "./chart"

const client = new ApolloClient({
  networkInterface: createNetworkInterface({
    uri: "/api",
  }),
});

client.query({
  query: gql`
    query {
      usStocks(symbol: "FB") {
        date
        openPrice
        closePrice
        lowestPrice
        highestPrice
        turnoverVol
      }
      donchianChannel(symbol: "FB", duration: 20) {
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

