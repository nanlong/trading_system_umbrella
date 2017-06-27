defmodule TradingSystem.Web.PageView do
  use TradingSystem.Web, :view

  def currency(price, precision \\ 2) do
    Float.ceil(price, precision)
  end
end
