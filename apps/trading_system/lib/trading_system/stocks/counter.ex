defmodule TradingSystem.Stocks.Counter do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :account, :string, virtual: true
    field :position, :integer, virtual: true
    field :atr_account_ratio, :float, virtual: true
    field :atr_add_step, :float, virtual: true
    field :atr_stop_step, :float, virtual: true
    field :buy_price, :float, virtual: true
    field :atr, :float, virtual: true
    field :trade, :string, virtual: true, default: :bull
  end

  @required_fields ~w(account position atr_account_ratio atr_add_step atr_stop_step buy_price atr trade)a
  @optional_fields ~w()a

  def changeset(struct, params) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end