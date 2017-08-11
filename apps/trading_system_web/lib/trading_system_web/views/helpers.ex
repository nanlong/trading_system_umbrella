defmodule TradingSystem.Web.Helpers do
  
  def vip?(user), do: TradingSystem.Accounts.vip?(user)

  def to_date(naive_datetime) do
    naive_datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_date()
  end
end