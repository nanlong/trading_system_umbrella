defmodule TradingSystem.Accounts.Session do
  use Ecto.Schema

  import Ecto.Changeset

  alias TradingSystem.Accounts

  embedded_schema do
    field :email, :string, virtual: true
    field :password, :string, virtual: false
  end

  @required_fields ~w(email password)a

  def changeset(struct, params) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields, message: "不能为空")
    |> validate_user
    |> validate_password
  end

  defp validate_user(%{valid?: false} = changeset), do: changeset
  defp validate_user(changeset) do
    with email <- get_field(changeset, :email),
      user <- Accounts.get_user!(email: email) do
        put_change(changeset, :user, user)
      else
        {:error, _} -> add_error(changeset, :email, "用户不存在")
      end
  end

  defp validate_password(%{valid?: false} = changeset), do: changeset
  defp validate_password(changeset) do
    with user <- get_field(changeset, :user),
      password <- get_field(changeset, :password),
      true <- Comeonin.Bcrypt.checkpw(password, user.password_hash) do
        changeset
      else
        false -> add_error(changeset, :password, "密码错误")
      end
  end
end