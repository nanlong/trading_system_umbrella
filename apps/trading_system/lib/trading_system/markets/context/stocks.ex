defmodule TradingSystem.Markets.StocksContext do
  
  import Ecto.Query, warn: false
  alias TradingSystem.Repo

  alias TradingSystem.Markets.Stocks
  alias TradingSystem.Markets.StockBlacklist
  alias TradingSystem.Markets.StockStar

  @cn_markets ["SH", "SZ"]
  @hk_markets ["HK"]
  @us_markets ["NASDAQ", "NYSE", "AMEX"]

  def create(attrs \\ %{}) do
    %Stocks{}
    |> Stocks.changeset(attrs)
    |> Repo.insert()
  end

  def update(%Stocks{} = stock, attrs) do
    stock
    |> Stocks.changeset(attrs)
    |> Repo.update()
  end

  def get(symbol: symbol), do: Repo.get_by(Stocks, symbol: symbol)
  def get!(symbol: symbol) do 
    Stocks
    |> query_load_state()
    |> Repo.get_by!(symbol: symbol)
  end

  def paginate(:cn, params), do: query_all_with_market(@cn_markets, params) |> query_paginate(params)
  def paginate(:cn_bull, params), do: query_bull_with_market(@cn_markets, params) |> query_paginate(params)
  def paginate(:cn_bear, params), do: query_bear_with_market(@cn_markets, params) |> query_paginate(params)
  def paginate(:cn_blacklist, params), do: query_blacklist_with_market(@cn_markets, params) |> query_paginate(params)
  def paginate(:cn_star, params), do: query_star_with_market(@cn_markets, params) |> query_paginate(params)
  def paginate(:hk, params), do: query_all_with_market(@hk_markets, params) |> query_paginate(params)
  def paginate(:hk_bull, params), do: query_bull_with_market(@hk_markets, params) |> query_paginate(params)
  def paginate(:hk_bear, params), do: query_bear_with_market(@hk_markets, params) |> query_paginate(params)
  def paginate(:hk_blacklist, params), do: query_blacklist_with_market(@hk_markets, params) |> query_paginate(params)
  def paginate(:hk_star, params), do: query_blacklist_with_market(@hk_markets, params) |> query_paginate(params)
  def paginate(:us, params), do: query_all_with_market(@us_markets, params) |> query_paginate(params)
  def paginate(:us_bull, params), do: query_bull_with_market(@us_markets, params) |> query_paginate(params)
  def paginate(:us_bear, params), do: query_bear_with_market(@us_markets, params) |> query_paginate(params)
  def paginate(:us_blacklist, params), do: query_blacklist_with_market(@us_markets, params) |> query_paginate(params)
  def paginate(:us_star, params), do: query_star_with_market(@us_markets, params) |> query_paginate(params)

  def list(:cn), do: query_list(@cn_markets)
  def list(:hk), do: query_list(@hk_markets)
  def list(:us), do: query_list(@us_markets)

  defp query_list(market) do  
    Stocks
    |> query_with_market(market)
    |> query_order_by()
    |> query_all()
  end

  defp query_all_with_market(market, params) do
    Stocks
    |> query_with_market(market)
    |> query_load_state()
    |> query_exclude_blacklist(Map.get(params, "user_id"))
    |> query_order_by()
  end

  defp query_bull_with_market(market, params) do
    Stocks
    |> query_with_market(market)
    |> query_load_state()
    |> query_exclude_blacklist(Map.get(params, "user_id"))
    |> query_bull()
    |> query_order_by()
  end

  defp query_bear_with_market(market, params) do
    Stocks
    |> query_with_market(market)
    |> query_load_state()
    |> query_exclude_blacklist(Map.get(params, "user_id"))
    |> query_bear()
    |> query_order_by()
  end

  defp query_blacklist_with_market(market, params) do
    Stocks
    |> query_with_market(market)
    |> query_load_state()
    |> query_include_blacklist(Map.get(params, "user_id"))
    |> query_order_by()
  end

  defp query_star_with_market(market, params) do
    Stocks
    |> query_with_market(market)
    |> query_load_state()
    |> query_include_star(Map.get(params, "user_id"))
    |> query_order_by()
  end

  defp query_with_market(query, market) do
    where(query, [stock], stock.market in ^market)
  end

  defp query_bull(query) do
    join(query, :inner, [stock], state in assoc(stock, :state), state.ma50 > state.ma300)
  end

  defp query_bear(query) do
    join(query, :inner, [stock], state in assoc(stock, :state), state.ma50 < state.ma300)
  end

  defp query_exclude_blacklist(query, user_id) when is_nil(user_id), do: query
  defp query_exclude_blacklist(query, user_id) do
    where(query, [stock], fragment("? NOT IN (SELECT symbol FROM stock_blacklist where user_id = ?)", stock.symbol, type(^user_id, Ecto.UUID)))
  end

  defp query_include_blacklist(query, user_id) when is_nil(user_id), do: query
  defp query_include_blacklist(query, user_id) do
    join(query, :inner, [stock], black in StockBlacklist, black.user_id == ^user_id and black.symbol == stock.symbol)
  end

  defp query_include_star(query, user_id) when is_nil(user_id), do: query
  defp query_include_star(query, user_id) do
    join(query, :inner, [stock], star in StockStar, star.user_id == ^user_id and star.symbol == stock.symbol)
  end

  defp query_load_state(query) do
    query
    |> where([stock], not is_nil(stock.stock_state_id))
    |> preload([], [:state])
  end

  defp query_order_by(query) do
    order_by(query, [stock], desc: stock.volume)
  end

  defp query_paginate(query, params) do
    Repo.paginate(query, params)
  end

  defp query_all(query) do
    Repo.all(query)
  end
end