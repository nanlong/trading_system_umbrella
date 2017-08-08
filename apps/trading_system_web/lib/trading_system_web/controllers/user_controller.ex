defmodule TradingSystem.Web.UserController do
  use TradingSystem.Web, :controller

  alias TradingSystem.Accounts
  alias TradingSystem.Accounts.User

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})

    conn
    |> assign(:title, "用户注册")
    |> assign(:changeset, changeset)
    |> render(:new)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "注册成功.")
        |> redirect(to: page_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> assign(:title, "用户注册")
        |> assign(:changeset, changeset)
        |> render(:new)
    end
  end
end
