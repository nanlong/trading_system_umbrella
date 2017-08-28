defmodule TradingSystem.Stocks.Stock do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Stocks.Stock


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "stocks" do
    field :symbol, :string
    field :name, :string
    field :cname, :string
    field :category, :string
    field :market_cap, :decimal # 市值
    field :pe, :string # 市盈率
    field :market, :string # 市场
    
    timestamps()
  end

  @required_fields ~w(symbol name cname)a
  @optioned_fields ~w(category market_cap pe market)a

  @doc false
  def changeset(%Stock{} = stock, attrs) do
    stock
    |> cast(attrs, @required_fields ++ @optioned_fields)
    |> validate_required(@required_fields)
  end
end
