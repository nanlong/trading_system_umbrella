defmodule TradingSystem.Graphql.Schema do
  use Absinthe.Schema
  import_types TradingSystem.Graphql.Types

  query do
    field :stocks, list_of(:stock) do
      resolve &TradingSystem.Graphql.StockResolver.all/2
    end

    field :stock, :stock do
      arg :symbol, :string, description: "股票代码"
      resolve &TradingSystem.Graphql.StockResolver.get/2
    end

    field :stock_state, list_of(:stock_state) do
      resolve &TradingSystem.Graphql.StockStateResolver.all/2
    end

    field :stock_realtime, list_of(:stock_realtime) do
      arg :stocks, :string, description: "股票代码，用逗号分隔"
      resolve &TradingSystem.Graphql.StockResolver.realtime/2
    end
  end
end