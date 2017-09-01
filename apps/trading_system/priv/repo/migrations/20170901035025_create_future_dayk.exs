defmodule TradingSystem.Repo.Migrations.CreateFutureDayk do
  use Ecto.Migration

  def change do
    create table(:future_dayk, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :date, :date
      add :symbol, :string
      add :open, :decimal
      add :highest, :decimal
      add :lowest, :decimal
      add :close, :decimal
      add :pre_close, :decimal
      add :volume, :integer

      timestamps()
    end

    create index(:future_dayk, [:date])
    create index(:future_dayk, [:symbol])
    create unique_index(:future_dayk, [:date, :symbol])
  end
end
