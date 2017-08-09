defmodule TradingSystem.Web.Plug.CurrentUser do
  import Plug.Conn, only: [assign: 3]

  alias TradingSystem.Accounts

  def init(opts \\ %{}), do: Enum.into(opts, %{})

  def call(conn, opts) do
    key = Map.get(opts, :key, :default)

    current_user = Guardian.Plug.current_resource(conn, key)

    user_config =
      case current_user do
        nil -> %{}
        user -> Accounts.get_config(user_id: user.id)
      end

    conn
    |> assign(gen_key(key, :authenticated?), Guardian.Plug.authenticated?(conn, key))
    |> assign(gen_key(key, :current_user), current_user)
    |> assign(:user_config, user_config)
  end

  defp gen_key(key, name) do
    (if key != :default, do: to_string(key) <> "_", else: "")
    |> join(to_string(name))
    |> String.to_atom
  end

  defp join(a, b) when is_binary(a) and is_binary(b) do
    a <> b
  end
end