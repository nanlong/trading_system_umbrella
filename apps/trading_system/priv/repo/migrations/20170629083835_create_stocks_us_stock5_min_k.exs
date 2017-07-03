defmodule TradingSystem.Repo.Migrations.CreateTradingSystem.Stocks.USStock5MinK do
  use Ecto.Migration

  def change do
    create table(:usstock_5mink, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :symbol, :string
      add :datetime, :naive_datetime
      add :open_price, :float
      add :close_price, :float
      add :lowest_price, :float
      add :highest_price, :float
      add :volume, :integer

      timestamps()
    end

    create index(:usstock_5mink, [:symbol])
    create unique_index(:usstock_5mink, [:symbol, :datetime])
  end
end
