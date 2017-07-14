defmodule TradingSystem.Graphql.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: TradingSystem.Repo

  @desc "美股"
  object :stock do
    field :symbol, :string
    field :cname, :string
    field :category, :string
  end

  @desc "美股实时"
  object :stock_realtime do
    field :symbol, :string
    field :cname, :string
    field :datetime, :string
    field :price, :float
    field :open, :float
    field :highest, :float
    field :lowest, :float
    field :w52_highest, :float
    field :w52_lowest, :float
    field :volume, :integer
    field :volume_10_avg, :integer
    field :market_cap, :integer
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