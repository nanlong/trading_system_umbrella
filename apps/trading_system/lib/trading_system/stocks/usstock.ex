defmodule TradingSystem.Stocks.USStock do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Stocks.USStock


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "usstocks" do
    field :name, :string
    field :symbol, :string
    field :last_sale, :decimal
    field :market_cap, :decimal

    timestamps()
  end

  @required_fields [:name, :symbol, :last_sale, :market_cap]

  @doc false
  def changeset(%USStock{} = usstock, attrs) do
    usstock
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
