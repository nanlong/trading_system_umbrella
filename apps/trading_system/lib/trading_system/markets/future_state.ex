defmodule TradingSystem.Markets.FutureState do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Markets.FutureState


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "future_state" do
    field :atr20, :decimal
    field :date, :date
    field :dca10, :decimal
    field :dca20, :decimal
    field :dca60, :decimal
    field :dcl10, :decimal
    field :dcl20, :decimal
    field :dcl60, :decimal
    field :dcu10, :decimal
    field :dcu20, :decimal
    field :dcu60, :decimal
    field :ma10, :decimal
    field :ma120, :decimal
    field :ma150, :decimal
    field :ma20, :decimal
    field :ma240, :decimal
    field :ma30, :decimal
    field :ma300, :decimal
    field :ma5, :decimal
    field :ma50, :decimal
    field :ma60, :decimal
    field :symbol, :string
    field :tr, :decimal

    timestamps()
  end

  @doc false
  def changeset(%FutureState{} = future_state, attrs) do
    future_state
    |> cast(attrs, [:date, :symbol, :dcu10, :dca10, :dcl10, :dcu20, :dca20, :dcl20, :dcu60, :dca60, :dcl60, :ma5, :ma10, :ma20, :ma30, :ma50, :ma60, :ma120, :ma150, :ma240, :ma300, :tr, :atr20])
    |> validate_required([:date, :symbol, :dcu10, :dca10, :dcl10, :dcu20, :dca20, :dcl20, :dcu60, :dca60, :dcl60, :ma5, :ma10, :ma20, :ma30, :ma50, :ma60, :ma120, :ma150, :ma240, :ma300, :tr, :atr20])
  end
end
