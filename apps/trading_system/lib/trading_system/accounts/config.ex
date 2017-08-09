defmodule TradingSystem.Accounts.Config do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Accounts.Config


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "configs" do
    field :atr_account_ratio, :float, default: 0.5
    field :atr_add_step, :float, default: 0.5
    field :atr_days, :integer, default: 20
    field :atr_stop_step, :float, default: 4.0
    field :close_days, :integer, default: 10
    field :create_days, :integer, default: 20
    field :user_id, :binary_id

    timestamps()
  end

  @required_fields ~w(user_id)a
  @optional_fields ~w(atr_account_ratio atr_add_step atr_days atr_stop_step close_days create_days)a
  
  @doc false
  def changeset(%Config{} = config, attrs) do
    config
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
