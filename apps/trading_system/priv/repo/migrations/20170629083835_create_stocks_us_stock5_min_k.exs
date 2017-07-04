defmodule TradingSystem.Repo.Migrations.CreateTradingSystem.Stocks.USStock5MinK do
  use Ecto.Migration

  def change do
    create table(:usstock_5mink, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :symbol, :string
      add :datetime, :naive_datetime
      add :open_price, :decimal
      add :close_price, :decimal
      add :lowest_price, :decimal
      add :highest_price, :decimal
      add :volume, :decimal

      timestamps()
    end

    create index(:usstock_5mink, [:symbol])
    create unique_index(:usstock_5mink, [:symbol, :datetime])
  end
end
