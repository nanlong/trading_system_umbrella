defmodule TradingSystem.Stocks.StockStar do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Stocks.StockStar
  alias TradingSystem.Stocks.Stock


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "stock_star" do
    field :symbol, :string

    belongs_to :stock, Stock, define_field: false, foreign_key: :symbol, references: :symbol
    timestamps()
  end

  @doc false
  def changeset(%StockStar{} = stock_star, attrs) do
    stock_star
    |> cast(attrs, [:symbol])
    |> validate_required([:symbol])
    |> unique_constraint(:symbol)
    |> assoc_constraint(:stock)
  end
end
