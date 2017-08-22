defmodule TradingSystem.Market.Stocks do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Market.Stocks


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
    
    timestamps()
  end

  @required_fields ~w(symbol name cname)a
  @optioned_fields ~w(category open highest lowest pre_close diff chg amplitude volume market_cap pe market)a

  @doc false
  def changeset(%Stocks{} = stock, attrs) do
    stock
    |> cast(attrs, @required_fields ++ @optioned_fields)
    |> validate_required(@required_fields)
  end
end
