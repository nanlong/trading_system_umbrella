defmodule TradingSystem.Graphql.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: TradingSystem.Repo

  @desc "美股行情"
  object :usstock do
    @desc "股票代码"
    field :symbol, :string
    @desc "日期"
    field :date, :string
    @desc "开盘价"
    field :open_price, :string
    @desc "收盘价"
    field :close_price, :string
    @desc "最低价"
    field :lowest_price, :string
    @desc "最高价"
    field :highest_price, :string
    @desc "前一日收盘价"
    field :pre_close_price, :string
    @desc "成交量"
    field :turnover_vol, :string
    @desc "涨跌幅"
    field :chg_pct, :string
  end

  @desc "唐奇安通道"
  object :donchian_channel do
    field :date, :string
    @desc "最高价"
    field :high, :string
    @desc "平均价"
    field :avg, :string
    @desc "最低价"
    field :low, :string
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
end