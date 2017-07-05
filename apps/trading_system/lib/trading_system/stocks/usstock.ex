defmodule TradingSystem.Stocks.USStock do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Stocks.USStock


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "usstocks" do
    field :symbol, :string
    field :name, :string
    field :cname, :string
    field :category, :string
    field :pre_close_price, :decimal
    field :open_price, :decimal
    field :highest_price, :decimal
    field :lowest_price, :decimal
    field :diff, :decimal
    field :chg, :decimal
    field :amplitude, :string
    field :volume, :decimal
    field :market_cap, :decimal
    field :pe, :string
    field :market, :string
    
    timestamps()
  end

  @required_fields [:symbol, :name, :cname]

  @doc false
  def changeset(%USStock{} = usstock, attrs) do
    usstock
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
