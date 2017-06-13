defmodule TradingSystem.Repo.Migrations.CreateTradingSystem.Stocks.USStockDailyPrices do
  use Ecto.Migration

  def change do
    create table(:us_stock_daily_prices, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :symbol, :string
      add :date, :date
      add :open_price, :decimal
      add :close_price, :decimal
      add :highest_price, :decimal
      add :lowest_price, :decimal
      add :pre_close_price, :decimal
      add :turnover_vol, :integer
      add :chg_pct, :float

      timestamps()
    end

    create index(:us_stock_daily_prices, [:symbol])
    create index(:us_stock_daily_prices, [:date])
    create unique_index(:us_stock_daily_prices, [:symbol, :date])
  end
end
