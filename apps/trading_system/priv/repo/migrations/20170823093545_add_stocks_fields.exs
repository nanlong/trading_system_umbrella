defmodule TradingSystem.Repo.Migrations.AddStocksFields do
  use Ecto.Migration

  def change do
    alter table(:stocks) do
      add :lot_size, :integer
    end
  end
end
