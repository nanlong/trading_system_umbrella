defmodule TradingSystem.Stocks.USStockDailyK do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Stocks.USStockDailyK


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "usstock_dailyk" do
    field :close_price, :decimal
    field :date, :date
    field :highest_price, :decimal
    field :lowest_price, :decimal
    field :open_price, :decimal
    field :symbol, :string
    field :volume, :decimal
    field :pre_close_price, :decimal

    timestamps()
  end

  @required_fields [:symbol, :date, :open_price, :close_price, :highest_price, 
    :lowest_price, :volume, :pre_close_price]
  @optional_fields ~w()a

  @doc false
  def changeset(%USStockDailyK{} = us_stock_daily_prices, attrs) do
    us_stock_daily_prices
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
