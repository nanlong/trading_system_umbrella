defmodule TradingSystem.Repo.Migrations.AlterStockBlacklistAndStarIndex do
  use Ecto.Migration

  def change do
    drop unique_index(:stock_blacklist, [:symbol])
    create unique_index(:stock_blacklist, [:symbol, :user_id])
    drop unique_index(:stock_star, [:symbol])
    create unique_index(:stock_star, [:symbol, :user_id])
  end
end
