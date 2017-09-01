defmodule TradingSystem.Accounts.UserContext do
  import Ecto.Query, warn: false
  alias TradingSystem.Repo
  alias TradingSystem.Accounts.User
  alias TradingSystem.Accounts.ConfigContext

  def vip?(%{vip_expire: vip_expire}) when is_nil(vip_expire), do: false
  def vip?(user) do 
    now = DateTime.utc_now()
    vip_expire = DateTime.from_naive!(user.vip_expire, "Etc/UTC")
    if DateTime.compare(now, vip_expire) == :lt, do: true, else: false
  end

  def get(email: email), do: Repo.get_by(User, email: email)
  def get(id), do: Repo.get(User, id)

  def get!(email: email), do: Repo.get_by!(User, email: email)
  def get!(id), do: Repo.get!(User, id)

  def create(attrs \\ %{}) do
    result =
      Ecto.Multi.new
      |> Ecto.Multi.insert(:user, User.changeset(%User{}, attrs))
      |> Ecto.Multi.run(:config, fn %{user: user} -> ConfigContext.create(%{user_id: user.id}) end)
      |> Repo.transaction()

    case result do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end
  
  def update(:profile, %User{} = user, attrs) do
    user
    |> User.changeset_profile(attrs)
    |> Repo.update()
  end
  def update(:password, %User{} = user, attrs) do
    user
    |> User.changeset_password(attrs)
    |> Repo.update()
  end
  def update(:password_reset, %User{} = user, attrs) do
    user
    |> User.changeset_password_reset(attrs)
    |> Repo.update()
  end

  def change(%User{} = user) do
    User.changeset(user, %{})
  end
  def change(:profile, %User{} = user) do
    User.changeset_profile(user, %{})
  end
  def change(:password, %User{} = user) do
    User.changeset_password(user, %{})
  end
  def change(:password_reset, %User{} = user) do
    User.changeset_password_reset(user, %{})
  end
end