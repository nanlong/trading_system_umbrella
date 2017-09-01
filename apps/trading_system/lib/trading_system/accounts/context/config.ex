defmodule TradingSystem.Accounts.ConfigContext do
  import Ecto.Query, warn: false
  alias TradingSystem.Repo
  alias TradingSystem.Accounts.Config

  def get(user_id: user_id) do
    case Repo.get_by(Config, user_id: user_id) do
      nil -> nil
      config ->
        config
        |> Map.from_struct()
        |> Map.delete(:__meta__)
        |> Map.delete(:id)
        |> Map.delete(:user_id)
        |> Map.delete(:inserted_at)
        |> Map.delete(:updated_at)
    end
  end

  def get!(user_id: user_id), do: Repo.get_by!(Config, user_id: user_id)

  def create(attrs \\ %{})
  def create(%{user_id: user_id} = attrs) do
    case get(user_id: user_id) do
      nil -> %Config{}
      config -> config
    end
    |> Config.changeset(attrs)
    |> Repo.insert_or_update()
  end
  def create(attrs) do
    {:error, %{Config.changeset(%Config{}, attrs) | action: :insert}}
  end

  def update(%Config{} = config, attrs) do
    config
    |> Config.changeset(attrs)
    |> Repo.update()
  end

  def change(%Config{} = config) do
    Config.changeset(config, %{})
  end
end