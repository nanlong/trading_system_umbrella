defmodule TradingSystem.Markets.Futures do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Markets.Futures


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "futures" do
    field :symbol, :string
    field :name, :string
    field :market, :string
    field :lot_size, :integer

    belongs_to :dayk, TradingSystem.Markets.FutureDayk, foreign_key: :future_dayk_id
    belongs_to :state, TradingSystem.Markets.FutureState, foreign_key: :future_state_id
    
    timestamps()
  end

  @required_fields ~w(symbol name market)a
  @optional_fields ~w(lot_size future_dayk_id future_state_id)

  @doc false
  def changeset(%Futures{} = futures, attrs) do
    futures
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
