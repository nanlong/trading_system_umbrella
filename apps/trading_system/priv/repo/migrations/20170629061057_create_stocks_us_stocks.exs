defmodule TradingSystem.Repo.Migrations.CreateTradingSystem.Stocks.USStocks do
  use Ecto.Migration

  def change do
    create table(:usstocks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :symbol, :string
      add :last_sale, :decimal
      add :market_cap, :decimal

      timestamps()
    end

    create unique_index(:usstocks, [:name, :symbol])
    create unique_index(:usstocks, [:symbol])
    create index(:usstocks, [:market_cap])
  end
end
