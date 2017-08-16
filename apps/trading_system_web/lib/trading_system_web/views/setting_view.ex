defmodule TradingSystem.Web.SettingView do
  use TradingSystem.Web, :view

  def close_days(20), do: 10
  def close_days(60), do: 20
end
