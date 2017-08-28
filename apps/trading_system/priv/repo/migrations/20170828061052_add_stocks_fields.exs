defmodule TradingSystem.Repo.Migrations.AddStocksFields do
  use Ecto.Migration

  def change do
    alter table(:stocks) do
      add :stock_dayk_id, references(:stock_dailyk, on_delete: :nothing, type: :binary_id)
    end
  end
end
