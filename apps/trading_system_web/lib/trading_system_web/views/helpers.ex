defmodule TradingSystem.Web.Helpers do
  
  def vip?(%{vip_expire: vip_expire} = user) when is_nil(vip_expire), do: false
  def vip?(user) do 
    now = DateTime.utc_now()
    vip_expire = DateTime.from_naive!(user.vip_expire, "Etc/UTC")
    if DateTime.compare(now, vip_expire) == :lt, do: true, else: false
  end

  def to_date(naive_datetime) do
    naive_datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_date()
  end
end