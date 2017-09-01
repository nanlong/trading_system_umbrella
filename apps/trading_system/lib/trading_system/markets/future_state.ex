defmodule TradingSystem.Markets.FutureState do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Markets.FutureState


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "future_state" do
    field :date, :date
    field :symbol, :string
    field :dcu10, :decimal
    field :dca10, :decimal
    field :dcl10, :decimal
    field :dcu20, :decimal
    field :dca20, :decimal
    field :dcl20, :decimal
    field :dcu60, :decimal
    field :dca60, :decimal
    field :dcl60, :decimal
    field :ma5, :decimal
    field :ma10, :decimal
    field :ma20, :decimal
    field :ma30, :decimal
    field :ma50, :decimal
    field :ma60, :decimal
    field :ma120, :decimal
    field :ma150, :decimal
    field :ma240, :decimal
    field :ma300, :decimal
    field :tr, :decimal
    field :atr20, :decimal

    belongs_to :future, TradingSystem.Markets.Futures, define_field: false, foreign_key: :symbol, references: :symbol

    timestamps()
  end

  @required_fields ~w(date symbol)a
  @optional_fields ~w(dcu10 dca10 dcl10 dcu20 dca20 dcl20 dcu60 dca60 dcl60 ma5 ma10 ma20 
                      ma30 ma50 ma60 ma120 ma150 ma240 ma300 tr atr20)a

  @doc false
  def changeset(%FutureState{} = future_state, attrs) do
    future_state
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
