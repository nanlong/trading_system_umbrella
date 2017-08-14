defmodule TradingSystem.Stocks.StockStar do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Stocks.StockStar
  alias TradingSystem.Stocks.Stock
  alias TradingSystem.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "stock_star" do
    field :symbol, :string

    belongs_to :stock, Stock, define_field: false, foreign_key: :symbol, references: :symbol
    belongs_to :user, User

    timestamps()
  end

  @required_fields ~w(symbol user_id)a
  @optional_fields ~w()a

  @doc false
  def changeset(%StockStar{} = stock_star, attrs) do
    stock_star
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:symbol)
    |> assoc_constraint(:stock)
    |> assoc_constraint(:user)
  end
end
