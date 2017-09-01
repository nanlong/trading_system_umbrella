defmodule TradingSystem.Repo.Migrations.CreateFutures do
  use Ecto.Migration

  def change do
    create table(:futures, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :symbol, :string
      add :lot_size, :integer
      add :market, :string
      add :future_dayk_id, references(:future_dayk, on_delete: :nothing, type: :binary_id)
      add :future_state_id, references(:future_state, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:futures, [:name])
    create index(:futures, [:symbol])
    create index(:futures, [:market])
    create index(:futures, [:future_dayk_id])
    create index(:futures, [:future_state_id])
  end
end
