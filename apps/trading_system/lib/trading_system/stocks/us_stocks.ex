defmodule TradingSystem.Stocks.USStocks do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Stocks.USStocks


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "usstocks" do
    field :name, :string
    field :symbol, :string

    timestamps()
  end

  @doc false
  def changeset(%USStocks{} = us_stocks, attrs) do
    us_stocks
    |> cast(attrs, [:name, :symbol])
    |> validate_required([:name, :symbol])
  end
end
