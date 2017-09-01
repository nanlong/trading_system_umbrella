defmodule TradingSystem.Markets.FutureDayk do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Markets.FutureDayk


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "future_dayk" do
    field :close, :decimal
    field :date, :date
    field :highest, :decimal
    field :lowest, :decimal
    field :open, :decimal
    field :pre_close, :decimal
    field :symbol, :string
    field :volume, :integer

    timestamps()
  end

  @doc false
  def changeset(%FutureDayk{} = future_dayk, attrs) do
    future_dayk
    |> cast(attrs, [:date, :symbol, :open, :highest, :lowest, :close, :pre_close, :volume])
    |> validate_required([:date, :symbol, :open, :highest, :lowest, :close, :pre_close, :volume])
  end
end
