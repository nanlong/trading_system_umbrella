defmodule TradingSystem.Stocks.USStock do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Stocks.USStock


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "usstocks" do
    field :name, :string
    field :symbol, :string

    timestamps()
  end

  @doc false
  def changeset(%USStock{} = usstock, attrs) do
    usstock
    |> cast(attrs, [:name, :symbol])
    |> validate_required([:name, :symbol])
  end
end
