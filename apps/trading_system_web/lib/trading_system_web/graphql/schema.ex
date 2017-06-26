defmodule TradingSystem.Graphql.Schema do
  use Absinthe.Schema
  import_types TradingSystem.Graphql.Types

  query do
    field :us_stocks, list_of(:us_stock) do
      arg :symbol, :string, description: "股票代码"
      resolve &TradingSystem.Graphql.USStockResolver.all/2
    end

    field :donchian_channel, list_of(:donchian_channel) do
      arg :symbol, :string, description: "股票代码"
      arg :duration, :integer, description: "持续时间"
      
      resolve &TradingSystem.Graphql.DonchianChannel.all/2
    end
  end
end