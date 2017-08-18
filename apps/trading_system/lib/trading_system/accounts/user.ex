defmodule TradingSystem.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias TradingSystem.Accounts.User
  alias TradingSystem.Accounts.Config


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :nickname, :string
    field :password_hash, :string
    field :vip_expire, :naive_datetime

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :old_password, :string, virtual: true

    has_one :config, Config
    timestamps()
  end

  @required_fields ~w(email password password_confirmation)a
  @optional_fields ~w(vip_expire)
  @regex_email ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields, message: "不能为空")
    |> unique_constraint(:email, name: :users_lower_email_index, message: "邮箱已存在")
    |> validate_format(:email, @regex_email, message: "请输入正确的邮箱地址")
    |> validate_length(:password, min: 6, max: 128, message: "密码长度6-128位")
    |> validate_confirmation(:password, message: "两次输入密码不一致")
    |> put_password_hash
    |> put_nickname
    |> put_vip(30)
  end

  def changeset_profile(%User{} = user, attrs) do
    user
    |> cast(attrs, [:nickname])
    |> validate_required([:nickname], message: "不能为空")
  end

  def changeset_password(%User{} = user, attrs) do
    user
    |> cast(attrs, [:old_password, :password, :password_confirmation])
    |> validate_required([:old_password, :password, :password_confirmation], message: "不能为空")
    |> checkpw(:old_password, message: "密码输入不正确")
    |> validate_length(:password, min: 6, max: 128, message: "密码长度6-128位")
    |> validate_confirmation(:password, message: "两次输入密码不一致")
    |> put_password_hash
  end

  def changeset_password_reset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation], message: "不能为空")
    |> validate_length(:password, min: 6, max: 128, message: "密码长度6-128位")
    |> validate_confirmation(:password, message: "两次输入密码不一致")
    |> put_password_hash
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

  defp checkpw(%{valid?: false} = changeset, _field, _opts), do: changeset
  defp checkpw(changeset, field, [message: message]) do
    if Comeonin.Bcrypt.checkpw(get_field(changeset, field), changeset.data.password_hash) do
      changeset
    else
      add_error(changeset, field, message)
    end
  end

  defp put_vip(%{valid?: false} = changeset, _days), do: changeset
  defp put_vip(changeset, days) do
    vip_expire = Timex.add(Timex.now, Timex.Duration.from_days(days)) |> Timex.to_datetime()
    put_change(changeset, :vip_expire, vip_expire)
  end
end
