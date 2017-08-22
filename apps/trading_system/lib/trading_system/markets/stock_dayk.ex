defmodule TradingSystem.Markets.StockDayk do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Markets.StockDayk


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "stock_dailyk" do
    field :date, :date
    field :symbol, :string
    field :open, :decimal
    field :highest, :decimal
    field :lowest, :decimal
    field :close, :decimal
    field :pre_close, :decimal
    field :volume, :decimal
    
    timestamps()
  end

  @required_fields ~w(date symbol)a
  @optional_fields ~w(open highest lowest close pre_close volume)a

  @doc false
  def changeset(%StockDayk{} = stock_dayk, attrs) do
    stock_dayk
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
