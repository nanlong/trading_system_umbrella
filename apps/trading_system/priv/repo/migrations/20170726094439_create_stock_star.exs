defmodule TradingSystem.Repo.Migrations.CreateStockStar do
  use Ecto.Migration

  def change do
    create table(:stock_star, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :symbol, :string

      timestamps()
    end

    create unique_index(:stock_star, [:symbol])
  end
end
