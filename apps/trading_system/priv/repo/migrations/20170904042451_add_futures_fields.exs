defmodule TradingSystem.Repo.Migrations.AddFuturesFields do
  use Ecto.Migration

  def change do
    alter table(:futures) do
      add :trading_unit, :string
      add :price_quote, :string
      add :minimum_price_change, :string
    end
  end
end
