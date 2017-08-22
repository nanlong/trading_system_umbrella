defmodule TradingSystem.Repo.Migrations.AddStocksFields do
  use Ecto.Migration

  def change do
    alter table(:stocks) do
      add :stock_state_id, references(:stock_state, on_delete: :nothing, type: :binary_id)
    end

    create index(:stocks, [:stock_state_id])
  end
end
