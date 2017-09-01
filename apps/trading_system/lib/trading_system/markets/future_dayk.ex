defmodule TradingSystem.Markets.FutureDayk do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Markets.FutureDayk


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "future_dayk" do
    field :date, :date
    field :symbol, :string
    field :open, :decimal
    field :close, :decimal
    field :highest, :decimal
    field :lowest, :decimal
    field :pre_close, :decimal
    field :volume, :integer

    belongs_to :future, TradingSystem.Markets.Futures, define_field: false, foreign_key: :symbol, references: :symbol

    timestamps()
  end

  @required_fields ~w(date symbol open close highest lowest pre_close volume)a
  @optional_fields ~w()a

  @doc false
  def changeset(%FutureDayk{} = future_dayk, attrs) do
    future_dayk
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
