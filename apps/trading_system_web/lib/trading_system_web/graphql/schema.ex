defmodule TradingSystem.Graphql.Schema do
  use Absinthe.Schema
  import_types TradingSystem.Graphql.Types

  query do
    field :usstocks, list_of(:usstock) do
      arg :symbol, :string, description: "股票代码"
      resolve &TradingSystem.Graphql.USStockResolver.all/2
    end

    field :donchian_channel, list_of(:donchian_channel) do
      arg :symbol, :string, description: "股票代码"
      
      resolve &TradingSystem.Graphql.DonchianChannel.all/2
    end

    field :usstock_realtime, list_of(:usstock_realtime) do
      arg :stocks, :string, description: "股票代码，用逗号分隔"
      resolve &TradingSystem.Graphql.USStockResolver.realtime/2
    end
  end
end