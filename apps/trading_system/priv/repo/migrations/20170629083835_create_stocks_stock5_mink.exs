defmodule TradingSystem.Repo.Migrations.CreateTradingSystem.Stocks.Stock5MinK do
  use Ecto.Migration

  def change do
    create table(:stock_5mink, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :symbol, :string
      add :datetime, :naive_datetime
      add :open, :decimal
      add :close, :decimal
      add :lowest, :decimal
      add :highest, :decimal
      add :volume, :decimal

      timestamps()
    end

    create index(:stock_5mink, [:symbol])
    create unique_index(:stock_5mink, [:symbol, :datetime])
  end
end
