defmodule TradingSystem.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Accounts.User


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :nickname, :string
    field :password_hash, :string
    field :vip_expire, :naive_datetime

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @required_fields ~w(email password password_confirmation)a
  @optional_fields ~w()
  @regex_email ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:email, name: :users_lower_email_index, message: "邮箱已存在")
    |> validate_format(:email, @regex_email, message: "请输入正确的邮箱地址")
    |> validate_length(:password, min: 6, max: 128, message: "密码长度6-128位")
    |> validate_confirmation(:password, message: "两次输入密码不一致")
    |> put_password_hash
    |> put_nickname
  end

  defp put_password_hash(%{valid?: false} = changeset), do: changeset
  defp put_password_hash(changeset) do
    password_hash = 
      changeset
      |> get_field(:password)
      |> Comeonin.Bcrypt.hashpwsalt

    put_change(changeset, :password_hash, password_hash)
  end

  defp put_nickname(%{valid?: false} = changeset), do: changeset
  defp put_nickname(changeset) do
    nickname =
      changeset
      |> get_field(:email)
      |> String.split("@") 
      |> List.first

    put_change(changeset, :nickname, nickname)
  end
end
