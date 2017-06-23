import "phoenix_html"
import ApolloClient, { createNetworkInterface } from "apollo-client"
import gql from "graphql-tag"
import echarts from "echarts"

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
        open_price
        close_price
        lowest_price
        highest_price
        turnover_vol
      }
    }
  `
})
.then(resp => console.log(resp.data.usStocks))
.catch(error => console.error(error))

