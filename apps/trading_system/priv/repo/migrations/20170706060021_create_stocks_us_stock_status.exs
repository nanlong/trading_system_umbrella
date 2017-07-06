defmodule TradingSystem.Repo.Migrations.CreateTradingSystem.Stocks.USStockStatus do
  use Ecto.Migration

  def change do
    create table(:usstock_status, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :date, :date
      add :symbol, :string
      add :high_60, :decimal
      add :high_20, :decimal
      add :low_20, :decimal
      add :low_10, :decimal
      add :avg_50_gt_300, :boolean, default: false, null: false
      add :n, :decimal
      add :n_ratio_60, :decimal
      add :n_ratio_20, :decimal

      timestamps()
    end

    create index(:usstock_status, [:date])
    create index(:usstock_status, [:symbol])
    create index(:usstock_status, [:avg_50_gt_300])
    create index(:usstock_status, [:n_ratio_60])
    create index(:usstock_status, [:n_ratio_20])
    create unique_index(:usstock_status, [:date, :symbol])
  end
end
