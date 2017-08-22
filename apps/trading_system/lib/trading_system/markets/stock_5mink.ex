defmodule TradingSystem.Markets.Stock5MinK do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Markets.Stock5MinK


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "stock_5mink" do
    field :datetime, :naive_datetime
    field :symbol, :string
    field :open, :decimal
    field :highest, :decimal
    field :lowest, :decimal
    field :close, :decimal
    field :volume, :decimal

    timestamps()
  end

  @required_fields ~w(datetime symbol)a
  @optional_fields ~w(open highest lowest close volume)

  @doc false
  def changeset(%Stock5MinK{} = stock_5mink, attrs) do
    stock_5mink
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
