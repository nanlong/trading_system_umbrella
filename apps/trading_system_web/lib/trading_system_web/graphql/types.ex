defmodule TradingSystem.Graphql.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: TradingSystem.Repo

  @desc "美股行情"
  object :usstock do
    @desc "股票代码"
    field :symbol, :string
    field :cname, :string
    field :category, :string
  end

  @desc "唐奇安通道"
  object :donchian_channel do
    field :date, :string
    field :high_d60, :float
    field :high_d20, :float
    field :low_d20, :float
    field :low_d10, :float
  end

  @desc "美股实时"
  object :usstock_realtime do
    field :symbol, :string
    field :cname, :string
    field :datetime, :string
    field :price, :float
    field :open_price, :float
    field :highest_price, :float
    field :lowest_price, :float
    field :year_highest, :float
    field :year_lowest, :float
    field :volume, :integer
    field :volume_10_avg, :integer
    field :market_cap, :integer
  end

  @desc "美股状态"
  object :usstock_state do
    field :date, :string
    field :symbol, :string
    field :high_d20, :float
    field :high_d60, :float
    field :low_d10, :float
    field :low_d20, :float
    field :n, :float
    field :n_ratio_d20, :float
    field :n_ratio_d60, :float
    field :avg_d50_gt_d300, :boolean
    field :price, :float
    field :random, :string
    field :stock, :usstock
  end
end