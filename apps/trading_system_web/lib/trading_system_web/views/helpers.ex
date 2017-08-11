defmodule TradingSystem.Web.Helpers do
  
  def vip?(user), do: TradingSystem.Accounts.vip?(user)

  def to_date(naive_datetime) do
    naive_datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_date()
  end

  def to_keyword(map) do
    Enum.map(map, fn({key, value}) -> {String.to_atom(key), value} end)
  end
end