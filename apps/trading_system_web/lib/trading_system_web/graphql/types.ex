defmodule TradingSystem.Graphql.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: TradingSystem.Repo

  @desc "美股行情"
  object :us_stock do
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
    field :max_price, :string
    @desc "平均价"
    field :mid_price, :string
    @desc "最低价"
    field :min_price, :string
  end
end