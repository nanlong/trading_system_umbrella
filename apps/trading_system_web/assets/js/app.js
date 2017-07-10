import "phoenix_html"
import ApolloClient, { createNetworkInterface } from "apollo-client"
import gql from "graphql-tag"
import $ from "jquery"

const client = new ApolloClient({
  networkInterface: createNetworkInterface({
    uri: "/api"
  }),
});

function update_item(data) {
  let symbol = data.symbol.replace("$", "_")
  let $realtime = $("#" + symbol + "-realtime")
  let $state = $("#" + symbol + "-state")

  $realtime.text("$" + data.price)

  if ($state.data("high60") < data.price) {
    $state.html(`<i class="fa fa-check" style="color: forestgreen;"></i>`)
  }
  else {
    $state.html(`<i class="fa fa-close" style="color: brown;"></i>`)
  }
}

function update_realtime(client, stocks) {
  client.query({
    query: gql`
      query USStockRealtime($stocks: String) {
        usstockRealtime(stocks: $stocks) {
          datetime
          symbol
          cname
          price
          openPrice
          highestPrice
          lowestPrice
          yearHighest
          yearLowest
          volume
          marketCap
        }
      }
    `,
    variables: {
      stocks: stocks
    },
    fetchPolicy: "network-only"
  })
  .then(resp => resp.data.usstockRealtime.map(data => update_item(data)))
  .catch(error => console.log(error))
}
update_realtime(client, CONFIG["symbols"])

setTimeout(function st() {
  update_realtime(client, CONFIG["symbols"])
  setTimeout(st, 1000)
}, 1000)


