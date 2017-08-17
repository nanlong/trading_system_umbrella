defmodule TradingSystem.Web.PasswordResetController do
  use TradingSystem.Web, :controller

  alias TradingSystem.Accounts
  alias TradingSystem.Web.Email
  
  def new(conn, %{"token" => token}) do
    with {:ok, user_id} <- Accounts.verify_token(token) do
      user = Accounts.get_user!(user_id)
      changeset = Accounts.change_password_reset(user)

      conn
      |> assign(:title, "密码重置")
      |> assign(:user, user)
      |> assign(:token, token)
      |> assign(:changeset, changeset)
      |> render("reset.html")
    else
      {:error, :invalid} ->
        conn
        |> put_flash(:error, "重置密码链接不正确")
        |> redirect(to: password_reset_path(conn, :new))
      {:error, :expired} ->
        conn
        |> put_flash(:error, "重置密码链接已过期")
        |> redirect(to: password_reset_path(conn, :new))
    end
  end

  def new(conn, _params) do
    changeset = Accounts.change_password_reset()

    conn
    |> assign(:title, "找回密码")
    |> assign(:changeset, changeset)
    |> render("new.html")
  end

  def create(conn, %{"password_reset" => password_reset_params}) do
    with {:ok, user} <- Accounts.create_password_reset(password_reset_params) do
      Email.password_reset(user)

      conn
      |> render("success.html")
    else
      {:error, changeset} ->
        conn
        |> assign(:title, "找回密码")
        |> assign(:changeset, changeset)
        |> render("new.html")
    end
  end

  def update(conn, %{"token" => token, "user" => user_params}) do
    with {:ok, _user} <- UserContext.update(token, user_params) do
      conn
      |> put_flash(:info, "密码重置成功，请登陆")
      |> redirect(to: session_path(conn, :create))
    else
      {:error, :invalid} ->
        conn
        |> put_flash(:error, "重置密码链接不正确")
        |> redirect(to: password_reset_path(conn, :new))
      {:error, :expired} ->
        conn
        |> put_flash(:error, "重置密码链接已过期")
        |> redirect(to: password_reset_path(conn, :new))
      {:error, changeset} ->
        conn
        |> assign(:title, "密码重置")
        |> assign(:user, changeset.data)
        |> assign(:token, token)
        |> assign(:changeset, changeset)
        |> render("reset.html")
    end
  end
end