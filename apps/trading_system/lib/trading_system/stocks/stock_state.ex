defmodule TradingSystem.Stocks.StockState do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Stocks.StockState
  alias TradingSystem.Stocks.Stock

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "stock_state" do
    field :date, :date
    field :symbol, :string
    field :DCU10, :decimal
    field :DCA10, :decimal
    field :DCL10, :decimal
    field :DCU20, :decimal
    field :DCA20, :decimal
    field :DCL20, :decimal
    field :DCU60, :decimal
    field :DCA60, :decimal
    field :DCL60, :decimal
    field :MA5, :decimal
    field :MA10, :decimal
    field :MA20, :decimal
    field :MA30, :decimal
    field :MA50, :decimal
    field :MA60, :decimal
    field :MA120, :decimal
    field :MA150, :decimal
    field :MA240, :decimal
    field :MA300, :decimal
    field :TR, :decimal
    field :ATR20, :decimal

    timestamps()

    belongs_to :stock, Stock, define_field: false, foreign_key: :symbol, references: :symbol
  end

  @required_fields ~w(date symbol)a
  @optional_fields ~w(DCU10 DCA10 DCL10 DCU20 DCA20 DCL20 DCU60 DCA60 DCL60 MA5 MA10 MA20 
                      MA30 MA50 MA60 MA120 MA150 MA240 MA300 TR ATR20)a

  @doc false
  def changeset(%StockState{} = stock_state, attrs) do
    stock_state
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
