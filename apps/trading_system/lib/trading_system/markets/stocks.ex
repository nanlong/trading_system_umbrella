defmodule TradingSystem.Markets.Stocks do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Markets.Stocks
  

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
    field :lot_size, :integer
    
    belongs_to :state, TradingSystem.Markets.StockState, foreign_key: :stock_state_id
    belongs_to :dayk, TradingSystem.Markets.StockDayk, foreign_key: :stock_dayk_id

    timestamps()
  end

  @required_fields ~w(symbol name cname market lot_size)a
  @optioned_fields ~w(category market_cap pe stock_state_id stock_dayk_id)a

  @doc false
  def changeset(%Stocks{} = stock, attrs) do
    stock
    |> cast(attrs, @required_fields ++ @optioned_fields)
    |> validate_required(@required_fields)
  end
end
