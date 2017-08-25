defmodule TradingSystem.Web.CNStocksView do
  use TradingSystem.Web, :view

  def tabs(conn) do
    [
      {"全部", "all", market_cn_stocks_path(conn, :index, tab: "all")},
      {"适合做多的", "bull", market_cn_stocks_path(conn, :index, tab: "bull")},
      {"适合做空的", "bear", market_cn_stocks_path(conn, :index, tab: "bear")},
      {"我的关注", "star", market_cn_stocks_path(conn, :index, tab: "star")},
      {"黑名单", "blacklist", market_cn_stocks_path(conn, :index, tab: "blacklist")},
    ]
  end
end
