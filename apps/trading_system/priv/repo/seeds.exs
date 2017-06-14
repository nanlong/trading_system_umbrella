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

# us_symbols = ["TSLA", "FB", "BABA", "GOOG", "MSFT", "AAPL", "NVDA", "BRK.B"]
us_symbols = ["TSLA"]

defmodule Api do
  @start_date "2010-01-01"
  @end_date Date.utc_today |> Date.to_string

  def get(symbol) do
    get_data(symbol, @start_date)
  end

  def get_data(symbol, date) do
    resp = USSTockApi.get("/getDailyKBar", symbol: symbol, startDate: date, endDate: @end_date).body
    
    case resp do
      [] ->
        :timer.sleep(1000)
        get_data(symbol, add_years(date))
      data -> data
    end
  end

  defp add_years(date, years \\ 1) do
    {year, month, day} = Date.from_iso8601!(date) |> Date.to_erl
    Date.from_erl!({year + years, month, day}) |> Date.to_string
  end
end


Enum.map(us_symbols, fn symbol -> 
  # resp = USSTockApi.get("/getDailyKBar", symbol: symbol, startDate: start_date, endDate: end_date).body
  resp = Api.get(symbol)

  data =
  Enum.map(resp, fn attrs -> 
    attrs = Map.put_new(attrs, :symbol, symbol)

    to_float = fn(s) -> 
      {f, _} = Float.parse(s)
      f  
    end

    attrs
    |> Map.take([:date, :highest_price, :lowest_price, :pre_close_price])
    |> Map.update!(:highest_price, &(to_float.(&1)))
    |> Map.update!(:lowest_price, &(to_float.(&1)))
    |> Map.update!(:pre_close_price, &(to_float.(&1)))
    
    # unless Stocks.get_us_stock_daily_prices(attrs) do
    #   Stocks.create_us_stock_daily_prices(attrs)
    # end
  end)

  IO.inspect data
  :timer.sleep(1000)
end)
