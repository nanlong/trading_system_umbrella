defmodule TradingSystem.Graphql.Schema do
  use Absinthe.Schema
  import_types TradingSystem.Graphql.Types

  query do
    field :stock_dailyk_line, list_of(:stock_dailyk) do
      arg :symbol, non_null(:string), description: "股票代码"
      resolve &TradingSystem.Graphql.StockDailyKResolver.all/2
    end

    field :stock_state, list_of(:stock_state) do
      resolve &TradingSystem.Graphql.StockStateResolver.all/2
    end

    field :stock_state_line, list_of(:stock_state) do
      arg :symbol, non_null(:string), description: "股票代码"
      resolve &TradingSystem.Graphql.StockStateResolver.all/2
    end

    field :stock_realtime, list_of(:stock_realtime) do
      arg :stocks, non_null(:string), description: "股票代码，用逗号分隔"
      resolve &TradingSystem.Graphql.StockResolver.realtime/2
    end

    field :stock_backtest, list_of(:stock_backtest) do
      arg :symbol, non_null(:string)
      resolve &TradingSystem.Graphql.StockBacktestResolver.all/2
    end

    field :cn_stock, :cn_stock do
      arg :symbol, non_null(:string)
      resolve &TradingSystem.Graphql.StockDetailResolver.get_cn/2
    end

    field :hk_stock, :hk_stock do
      arg :symbol, non_null(:string)
      resolve &TradingSystem.Graphql.StockDetailResolver.get_hk/2
    end
  end

  mutation do
    field :create_stock_backlist, :stock do
      arg :symbol, non_null(:string)
      resolve &TradingSystem.Graphql.StockBlacklistResolver.create/2
    end

    field :delete_stock_backlist, :stock do
      arg :symbol, non_null(:string)
      resolve &TradingSystem.Graphql.StockBlacklistResolver.delete/2
    end

    field :create_stock_star, :stock do
      arg :symbol, non_null(:string)
      resolve &TradingSystem.Graphql.StockStarResolver.create/2
    end

    field :delete_stock_star, :stock do
      arg :symbol, non_null(:string)
      resolve &TradingSystem.Graphql.StockStarResolver.delete/2
    end
  end
end