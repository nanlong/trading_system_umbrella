defmodule TradingSystem.Repo.Migrations.CreateTradingSystem.Stocks.StockState do
  use Ecto.Migration

  def change do
    create table(:stock_state, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :date, :date
      add :symbol, :string
      add :DCU10, :decimal
      add :DCA10, :decimal
      add :DCL10, :decimal
      add :DCU20, :decimal
      add :DCA20, :decimal
      add :DCL20, :decimal
      add :DCU60, :decimal
      add :DCA60, :decimal
      add :DCL60, :decimal
      add :MA5, :decimal
      add :MA10, :decimal
      add :MA20, :decimal
      add :MA30, :decimal
      add :MA50, :decimal
      add :MA60, :decimal
      add :MA120, :decimal
      add :MA150, :decimal
      add :MA240, :decimal
      add :MA300, :decimal
      add :TR, :decimal
      add :ATR20, :decimal

      timestamps()
    end

    create index(:stock_state, [:date])
    create index(:stock_state, [:symbol])
  end
end
