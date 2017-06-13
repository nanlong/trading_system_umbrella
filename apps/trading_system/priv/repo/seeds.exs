# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TradingSystem.Repo.insert!(%TradingSystem.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TradingApi.LiangYee.USStock, as: USSTockApi
alias TradingSystem.Stocks

us_symbols = ["TSLA", "FB", "BABA", "GOOG", "MSFT", "AAPL", "NVDA"]

defmodule Api do
  @start_date "2010-01-01"
  @end_date Date.utc_today |> Date.to_string

  def get(symbol) do
    get_data(symbol, @start_date)
  end

  def get_data(symbol, date) do
    resp = USSTockApi.get("/getDailyKBar", symbol: symbol, startDate: date, endDate: @end_date).body
    IO.inspect resp
    case resp do
      [] ->
        {year, month, day} = Date.from_iso8601!(date) |> Date.to_erl
        date = Date.from_erl!({year + 1, month, day}) |> Date.to_string
        :timer.sleep(1000)
        get_data(symbol, date)
      data -> data
    end
  end
end


Enum.map(us_symbols, fn symbol -> 
  # resp = USSTockApi.get("/getDailyKBar", symbol: symbol, startDate: start_date, endDate: end_date).body
  resp = Api.get(symbol)

  Enum.map(resp, fn attrs -> 
    attrs = Map.put_new(attrs, :symbol, symbol)

    unless Stocks.get_us_stock_daily_prices(attrs) do
      Stocks.create_us_stock_daily_prices(attrs)
    end
  end)

  :timer.sleep(1000)
end)
