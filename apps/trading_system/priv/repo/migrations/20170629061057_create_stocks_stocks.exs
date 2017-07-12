defmodule TradingSystem.Repo.Migrations.CreateTradingSystem.Stocks.USStocks do
  use Ecto.Migration

  def change do
    create table(:stocks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :symbol, :string
      add :name, :string
      add :cname, :string
      add :category, :string
      add :pre_close, :decimal
      add :open, :decimal
      add :highest, :decimal
      add :lowest, :decimal
      add :diff, :decimal # 涨跌额
      add :chg, :decimal # 涨跌幅
      add :amplitude, :string # 振幅
      add :volume, :decimal # 成交量
      add :market_cap, :decimal # 市值
      add :pe, :string # 市盈率
      add :market, :string # 市场

      timestamps()
    end

    create unique_index(:stocks, [:name, :symbol])
    create unique_index(:stocks, [:symbol])
    create index(:stocks, [:market_cap])
  end
end
