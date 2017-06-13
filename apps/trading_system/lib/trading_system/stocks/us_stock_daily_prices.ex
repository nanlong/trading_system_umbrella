defmodule TradingSystem.Stocks.USStockDailyPrices do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Stocks.USStockDailyPrices


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "us_stock_daily_prices" do
    field :chg_pct, :float
    field :close_price, :decimal
    field :datetime, :naive_datetime
    field :highest_price, :decimal
    field :lowest_price, :decimal
    field :open_price, :decimal
    field :symbol, :string
    field :turnover_vol, :integer

    timestamps()
  end

  @doc false
  def changeset(%USStockDailyPrices{} = us_stock_daily_prices, attrs) do
    us_stock_daily_prices
    |> cast(attrs, [:symbol, :datetime, :open_price, :close_price, :highest_price, :lowest_price, :turnover_vol, :chg_pct])
    |> validate_required([:symbol, :datetime, :open_price, :close_price, :highest_price, :lowest_price, :turnover_vol, :chg_pct])
  end
end
