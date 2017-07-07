defmodule TradingSystem.Stocks.USStockStatus do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Stocks.USStockStatus
  alias TradingSystem.Stocks.USStock

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "usstock_status" do
    field :avg_50_gt_300, :boolean, default: false
    field :date, :date
    field :high_20, :decimal
    field :high_60, :decimal
    field :low_10, :decimal
    field :low_20, :decimal
    field :n, :decimal
    field :n_ratio_20, :decimal
    field :n_ratio_60, :decimal
    field :symbol, :string

    timestamps()

    belongs_to :stock, USStock, define_field: false, foreign_key: :symbol, references: :symbol
  end

  @required_fields ~w(date symbol)a
  @optional_fields ~w(high_60 high_20 low_20 low_10 avg_50_gt_300 n n_ratio_60 n_ratio_20)a

  @doc false
  def changeset(%USStockStatus{} = us_stock_status, attrs) do
    us_stock_status
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
