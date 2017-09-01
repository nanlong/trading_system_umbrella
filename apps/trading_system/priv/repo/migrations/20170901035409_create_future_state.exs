defmodule TradingSystem.Repo.Migrations.CreateFutureState do
  use Ecto.Migration

  def change do
    create table(:future_state, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :date, :date
      add :symbol, :string
      add :dcu10, :decimal
      add :dca10, :decimal
      add :dcl10, :decimal
      add :dcu20, :decimal
      add :dca20, :decimal
      add :dcl20, :decimal
      add :dcu60, :decimal
      add :dca60, :decimal
      add :dcl60, :decimal
      add :ma5, :decimal
      add :ma10, :decimal
      add :ma20, :decimal
      add :ma30, :decimal
      add :ma50, :decimal
      add :ma60, :decimal
      add :ma120, :decimal
      add :ma150, :decimal
      add :ma240, :decimal
      add :ma300, :decimal
      add :tr, :decimal
      add :atr20, :decimal

      timestamps()
    end

    create index(:future_state, [:date])
    create index(:future_state, [:symbol])
    create unique_index(:future_state, [:date, :symbol])
    create index(:future_state, [:ma50])
    create index(:future_state, [:ma300])
  end
end
