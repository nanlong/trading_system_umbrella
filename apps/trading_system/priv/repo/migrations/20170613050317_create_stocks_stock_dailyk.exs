defmodule TradingSystem.Repo.Migrations.CreateTradingSystem.Stocks.StockDailyPrices do
  use Ecto.Migration

  def change do
    create table(:stock_dailyk, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :date, :date
      add :symbol, :string
      add :open, :decimal
      add :highest, :decimal
      add :lowest, :decimal
      add :close, :decimal
      add :pre_close, :decimal
      add :volume, :decimal

      timestamps()
    end

    create index(:stock_dailyk, [:symbol])
    create index(:stock_dailyk, [:date])
    create unique_index(:stock_dailyk, [:symbol, :date])
  end
end
