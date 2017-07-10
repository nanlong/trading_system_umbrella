import "phoenix_html"
import ApolloClient, { createNetworkInterface } from "apollo-client"
import gql from "graphql-tag"
import $ from "jquery"

const client = new ApolloClient({
  networkInterface: createNetworkInterface({
    uri: "/api"
  }),
});

const break_stocks = new Set()

function render_break() {
  const $el = $("#break")
  let html = []

  for (let symbol of break_stocks) {
    html.push(`<a class="button is-small " href="/usstocks/${symbol}" target="_blank">${symbol}</a>`)
  }

  html = html.join("")

  if (html) {
    $el.html("突破：" + html).show()
  }
  else {
    $el.html("").hide()
  }
  
}

function add_break(symbol) {
  break_stocks.add(symbol)
  render_break()
}

function delete_break(symbol) {
  break_stocks.delete(symbol)
  render_break()
}

function update_item(data) {
  let symbol = data.symbol.replace("$", "_")
  let $realtime = $("#" + symbol + "-realtime")
  let $state = $("#" + symbol + "-state")

  $realtime.text("$" + data.price)

  if ($state.data("high60") < data.price) {
    add_break(data.symbol)
    $state.html(`<i class="fa fa-check" style="color: forestgreen;"></i>`)
  }
  else {
    delete_break(data.symbol)
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

function main() {
  update_realtime(client, CONFIG["symbols"])

  setTimeout(function st() {
    update_realtime(client, CONFIG["symbols"])
    setTimeout(st, 1000)
  }, 1000)
}

main()



