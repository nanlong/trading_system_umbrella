defmodule TradingSystem.Graphql.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: TradingSystem.Repo

  scalar :decimal, description: "Decimal" do
    parse &Decimal.new(&1)
    serialize &Decimal.to_float(&1)
  end

  @desc "美股详情"
  object :stock do
    field :symbol, :string
    field :name, :string
    field :cname, :string
    field :category, :string
    field :open, :float
    field :highest, :float
    field :lowest, :float
    field :pre_close, :float
    field :diff, :float
    field :chg, :float
    field :amplitude, :string
    field :volume, :float
    field :market_cap, :float
    field :pe, :string
    field :market, :string
  end

  @desc "美股日k"
  object :stock_dailyk do
    field :date, :string
    field :symbol, :string
    field :open, :decimal
    field :highest, :decimal
    field :lowest, :decimal
    field :close, :decimal
    field :pre_close, :decimal
    field :volume, :integer
  end

  @desc "美股实时"
  object :stock_realtime do
    field :symbol, :string
    field :cname, :string
    field :datetime, :string
    field :price, :float
    field :chg, :float
    field :diff, :float
    field :open, :float
    field :volume, :integer
    field :volume_d10_avg, :integer
    field :pre_close, :float
    field :highest, :float
    field :lowest, :float
    field :w52_highest, :float
    field :w52_lowest, :float
    field :pe, :integer
    field :eps, :float
    field :beta, :float
    field :market_cap, :integer
    field :capital, :float
    field :dividend, :float
    field :yield, :float
    field :random, :integer
  end

  @desc "美股状态"
  object :stock_state do
    field :date, :string
    field :symbol, :string
    field :dcu10, :float
    field :dca10, :float
    field :dcl10, :float
    field :dcu20, :float
    field :dca20, :float
    field :dcl20, :float
    field :dcu60, :float
    field :dca60, :float
    field :dcl60, :float
    field :ma5, :float
    field :ma10, :float
    field :ma20, :float
    field :ma30, :float
    field :ma50, :float
    field :ma60, :float
    field :ma120, :float
    field :ma150, :float
    field :ma240, :float
    field :ma300, :float
    field :tr, :float
    field :atr20, :float
    field :stock, :stock
    field :price, :float
    field :random, :integer
  end
end