defmodule TradingSystem.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias TradingSystem.Repo

  alias TradingSystem.Accounts.User

  def vip?(%{vip_expire: vip_expire}) when is_nil(vip_expire), do: false
  def vip?(user) do 
    now = DateTime.utc_now()
    vip_expire = DateTime.from_naive!(user.vip_expire, "Etc/UTC")
    if DateTime.compare(now, vip_expire) == :lt, do: true, else: false
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(email: email), do: Repo.get_by!(User, email: email)
  def get_user!(id), do: Repo.get!(User, id)
  def get_user(email: email), do: Repo.get_by(User, email: email)
  def get_user(id), do: Repo.get(User, id)
  def get_user_by(email: email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, nil}
      user -> {:ok, user}
    end
  end
  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    result =
      Ecto.Multi.new
      |> Ecto.Multi.insert(:user, User.changeset(%User{}, attrs))
      |> Ecto.Multi.run(:config, fn %{user: user} -> create_config(%{user_id: user.id}) end)
      |> Repo.transaction()

    case result do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(:profile, %User{} = user, attrs) do
    user
    |> User.changeset_profile(attrs)
    |> Repo.update()
  end

  def update_user(:password, %User{} = user, attrs) do
    user
    |> User.changeset_password(attrs)
    |> Repo.update()
  end

  def update_user(:password_reset, %User{} = user, attrs) do
    user
    |> User.changeset_password_reset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def change_user(:profile, %User{} = user) do
    User.changeset_profile(user, %{})
  end

  def change_user(:password, %User{} = user) do
    User.changeset_password(user, %{})
  end

  def change_user(:password_reset, %User{} = user) do
    User.changeset_password_reset(user, %{})
  end


  alias TradingSystem.Accounts.Session
  import Ecto.Changeset

  def create_session(attrs \\ %{}) do
    changeset = Session.changeset(%Session{}, attrs)

    if changeset.valid? do
      {:ok, get_field(changeset, :user)}
    else
      {:error, %{changeset | action: :create}}
    end
  end

  def change_session(%Session{} = session) do
    Session.changeset(session, %{})
  end

  alias TradingSystem.Accounts.Config

  @doc """
  Returns the list of configs.

  ## Examples

      iex> list_configs()
      [%Config{}, ...]

  """
  def list_configs do
    Repo.all(Config)
  end

  @doc """
  Gets a single config.

  Raises `Ecto.NoResultsError` if the Config does not exist.

  ## Examples

      iex> get_config!(123)
      %Config{}

      iex> get_config!(456)
      ** (Ecto.NoResultsError)

  """
  def get_config!(user_id: user_id), do: Repo.get_by!(Config, user_id: user_id)
  def get_config!(id), do: Repo.get!(Config, id)

  def get_config(user_id: user_id), do: Repo.get_by(Config, user_id: user_id)

  def preload_config(user), do: Repo.preload(user, :config)
  @doc """
  Creates a config.

  ## Examples

      iex> create_config(%{field: value})
      {:ok, %Config{}}

      iex> create_config(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_config(attrs \\ %{})
  def create_config(%{user_id: user_id} = attrs) do
    case get_config(user_id: user_id) do
      nil -> %Config{}
      config -> config
    end
    |> Config.changeset(attrs)
    |> Repo.insert_or_update()
  end
  def create_config(attrs) do
    {:error, %{Config.changeset(%Config{}, attrs) | action: :insert}}
  end

  @doc """
  Updates a config.

  ## Examples

      iex> update_config(config, %{field: new_value})
      {:ok, %Config{}}

      iex> update_config(config, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_config(%Config{} = config, attrs) do
    config
    |> Config.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Config.

  ## Examples

      iex> delete_config(config)
      {:ok, %Config{}}

      iex> delete_config(config)
      {:error, %Ecto.Changeset{}}

  """
  def delete_config(%Config{} = config) do
    Repo.delete(config)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking config changes.

  ## Examples

      iex> change_config(config)
      %Ecto.Changeset{source: %Config{}}

  """
  def change_config(%Config{} = config) do
    Config.changeset(config, %{})
  end

  def sign_token(user, token_name \\ "user_id") do
    Phoenix.Token.sign(TradingSystem.Web.Endpoint, token_name, user.id)
  end

  def verify_token(token, token_name \\ "user_id", max_age \\ 60 * 60 * 12 * 30) do
    case Phoenix.Token.verify(TradingSystem.Web.Endpoint, token_name, token, max_age: max_age) do
      {:ok, user_id} -> 
        case get_user(user_id) do
          nil -> {:error, "invalid authorization token"}
          user -> {:ok, user}
        end
      {:error, _} -> {:error, "invalid authorization token"}
    end
  end

  alias TradingSystem.Accounts.PasswordReset

  def change_password_reset(attrs \\ %{}) do
    %PasswordReset{}
    |> PasswordReset.changeset_email(attrs)
  end

  def create_password_reset(attrs \\ %{}) do
    changeset = change_password_reset(attrs)
    
    if changeset.valid? do
      {:ok, PasswordReset.get_user(changeset)}
    else
      {:error, %{changeset | action: :create}}
    end
  end
end
