defmodule TradingSystem.Markets.Futures do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Markets.Futures


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "futures" do
    field :lot_size, :integer
    field :market, :string
    field :name, :string
    field :symbol, :string
    field :future_dayk_id, :binary_id
    field :future_state_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(%Futures{} = futures, attrs) do
    futures
    |> cast(attrs, [:name, :symbol, :lot_size, :market])
    |> validate_required([:name, :symbol, :lot_size, :market])
  end
end
