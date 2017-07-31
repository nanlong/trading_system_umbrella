defmodule TradingSystem.Graphql.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: TradingSystem.Repo

  scalar :decimal, description: "Decimal" do
    parse &Decimal.new(&1)
    serialize fn
      (x) when is_bitstring(x) -> String.to_float(x)
      (x) -> Decimal.to_float(x)
    end
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
    field :dcu10, :decimal
    field :dca10, :decimal
    field :dcl10, :decimal
    field :dcu20, :decimal
    field :dca20, :decimal
    field :dcl20, :decimal
    field :dcu60, :decimal
    field :dca60, :decimal
    field :dcl60, :decimal
    field :ma5, :decimal
    field :ma10, :decimal
    field :ma20, :decimal
    field :ma30, :decimal
    field :ma50, :decimal
    field :ma60, :decimal
    field :ma120, :decimal
    field :ma150, :decimal
    field :ma240, :decimal
    field :ma300, :decimal
    field :tr, :decimal
    field :atr20, :decimal
    field :stock, :stock
    field :price, :decimal
    field :random, :integer
  end

  @desc "回测"
  object :stock_backtest do
    field :date, :string
    field :init_account, :float
    field :account, :float
    field :action, :string
    field :price, :float
    field :unit, :integer
    field :position, :integer
    field :market_cap, :float
  end
end