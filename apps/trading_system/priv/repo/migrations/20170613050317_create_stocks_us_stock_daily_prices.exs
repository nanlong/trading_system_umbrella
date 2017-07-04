defmodule TradingSystem.Repo.Migrations.CreateTradingSystem.Stocks.USStockDailyPrices do
  use Ecto.Migration

  def change do
    create table(:usstock_dailyk, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :symbol, :string
      add :date, :date
      add :open_price, :decimal
      add :close_price, :decimal
      add :highest_price, :decimal
      add :lowest_price, :decimal
      add :pre_close_price, :decimal
      add :volume, :integer
      add :chg_pct, :decimal

      timestamps()
    end

    create index(:usstock_dailyk, [:symbol])
    create index(:usstock_dailyk, [:date])
    create unique_index(:usstock_dailyk, [:symbol, :date])
  end
end
