defmodule TradingSystem.Repo.Migrations.AddAndRemoveStocksFields do
  use Ecto.Migration

  def change do
    alter table(:stocks) do
      add :stock_dayk_id, references(:stock_dailyk, on_delete: :nothing, type: :binary_id)
      remove :open
      remove :highest
      remove :lowest
      remove :pre_close
      remove :diff
      remove :chg
      remove :amplitude
      remove :volume
    end
  end
end
