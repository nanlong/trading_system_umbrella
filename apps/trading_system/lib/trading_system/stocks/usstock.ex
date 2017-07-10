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
    field :diff, :decimal # 涨跌额
    field :chg, :decimal # 涨跌幅
    field :amplitude, :string # 振幅
    field :volume, :decimal # 成交量
    field :market_cap, :decimal # 市值
    field :pe, :string # 市盈率
    field :market, :string # 市场
    
    timestamps()
  end

  @required_fields [:symbol, :name, :cname]
  @optioned_fields [:category, :pre_close_price, :open_price, :highest_price, :lowest_price,
                    :diff, :chg, :amplitude, :volume, :market_cap, :pe, :market]

  @doc false
  def changeset(%USStock{} = usstock, attrs) do
    usstock
    |> cast(attrs, @required_fields ++ @optioned_fields)
    |> validate_required(@required_fields)
  end
end
