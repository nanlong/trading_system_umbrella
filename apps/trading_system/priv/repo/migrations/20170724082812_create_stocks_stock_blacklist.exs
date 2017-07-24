defmodule TradingSystem.Repo.Migrations.CreateTradingSystem.Stocks.StockBlacklist do
  use Ecto.Migration

  def change do
    create table(:stock_blacklist, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :symbol, :string

      timestamps()
    end

    create unique_index(:stock_blacklist, [:symbol])
  end
end
