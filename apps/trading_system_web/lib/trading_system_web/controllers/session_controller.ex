defmodule TradingSystem.Web.SessionController do
  use TradingSystem.Web, :controller

  alias TradingSystem.Accounts
  alias TradingSystem.Accounts.Session

  def new(conn, _params) do
    changeset = Accounts.change_session(%Session{})

    conn
    |> assign(:title, "用户登录")
    |> assign(:changeset, changeset)
    |> render(:new)
  end

  def create(conn, %{"session" => session_params}) do
    case Accounts.create_session(session_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "登录成功.")
        |> redirect(to: page_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> assign(:title, "用户登录")
        |> assign(:changeset, changeset)
        |> render(:new)
    end
  end
end
