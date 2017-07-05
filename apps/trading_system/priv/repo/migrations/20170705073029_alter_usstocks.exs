defmodule TradingSystem.Repo.Migrations.AlterUsstocks do
  use Ecto.Migration

  def change do
    alter table(:usstocks) do
      add :cname, :string
      add :category, :string
      add :open_price, :decimal
      add :highest_price, :decimal
      add :lowest_price, :decimal
      add :diff, :decimal
      add :chg, :decimal
      add :amplitude, :string
      add :volume, :decimal
      add :pe, :string
      add :market, :string
    end

    rename table(:usstocks), :last_sale, to: :pre_close_price

    alter table(:usstock_dailyk) do
      remove :chg_pct
    end
  end
end
