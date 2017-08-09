defmodule TradingSystem.Repo.Migrations.CreateConfigs do
  use Ecto.Migration

  def change do
    create table(:configs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account, :float
      add :position, :integer
      add :atr_days, :integer
      add :atr_account_ratio, :float
      add :atr_add_step, :float
      add :atr_stop_step, :float
      add :create_days, :integer
      add :close_days, :integer
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:configs, [:user_id])
  end
end
