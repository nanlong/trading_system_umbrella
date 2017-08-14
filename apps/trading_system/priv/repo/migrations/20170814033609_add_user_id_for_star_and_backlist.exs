defmodule TradingSystem.Repo.Migrations.AddUserIdForStarAndBacklist do
  use Ecto.Migration

  def change do
    alter table(:stock_star) do
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
    end

    alter table(:stock_blacklist) do
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
    end

    create index(:stock_star, [:user_id])
    create index(:stock_blacklist, [:user_id])
  end
end
