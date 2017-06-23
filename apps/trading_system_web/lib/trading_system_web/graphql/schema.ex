defmodule TradingSystem.Graphql.Schema do
  use Absinthe.Schema
  import_types TradingSystem.Graphql.Types

  query do
    field :us_stocks, list_of(:us_stock) do
      arg :symbol, :string, description: "股票代码"
      resolve &TradingSystem.Graphql.USStockResolver.all/2
    end
  end
end