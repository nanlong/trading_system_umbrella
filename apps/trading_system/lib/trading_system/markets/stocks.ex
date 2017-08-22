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
    field :open, :decimal
    field :highest, :decimal
    field :lowest, :decimal
    field :pre_close, :decimal
    field :diff, :decimal # 涨跌额
    field :chg, :decimal # 涨跌幅
    field :amplitude, :string # 振幅
    field :volume, :decimal # 成交量
    field :market_cap, :decimal # 市值
    field :pe, :string # 市盈率
    field :market, :string # 市场
    
    belongs_to :state, TradingSystem.Markets.StockState, foreign_key: :stock_state_id

    timestamps()
  end

  @required_fields ~w(symbol name cname market)a
  @optioned_fields ~w(category open highest lowest pre_close diff chg amplitude volume market_cap pe stock_state_id)a

  @doc false
  def changeset(%Stocks{} = stock, attrs) do
    stock
    |> cast(attrs, @required_fields ++ @optioned_fields)
    |> validate_required(@required_fields)
  end
end
