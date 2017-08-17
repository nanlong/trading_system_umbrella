defmodule TradingSystem.Accounts.PasswordReset do
  use Ecto.Schema

  import Ecto.Changeset

  alias TradingSystem.Accounts

  embedded_schema do
    field :email, :string, virtual: true
  end

  @required_fields ~w(email)a

  def changeset(struct, params) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields, message: "不能为空")
    |> validate_user
  end

  defp validate_user(%{valid?: false} = changeset), do: changeset
  defp validate_user(changeset) do
    IO.inspect get_field(changeset, :email)
    with email <- get_field(changeset, :email),
      {:ok, user} <- Accounts.get_user_by(email: email) do
        put_change(changeset, :user, user)
      else
        {:error, _} -> add_error(changeset, :email, "用户不存在")
      end
  end

  def get_user(%Ecto.Changeset{} = changeset) do
    get_field(changeset, :user)
  end
end