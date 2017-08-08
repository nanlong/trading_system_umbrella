defmodule TradingSystem.Web.SessionControllerTest do
  use TradingSystem.Web.ConnCase

  alias TradingSystem.Accounts

  @user_attrs %{email: "test@qushi.pro", password: "123456", password_confirmation: "123456"}
  @create_attrs %{email: "test@qushi.pro", password: "123456"}
  @invalid_attrs %{email: nil, password: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end

  describe "new session" do
    test "renders form", %{conn: conn} do
      conn = get conn, session_path(conn, :new)
      assert html_response(conn, 200) =~ "用户登录"
    end
  end

  describe "create session" do
    setup [:create_user]

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, session_path(conn, :create), session: @create_attrs
      assert redirected_to(conn) == page_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, session_path(conn, :create), session: @invalid_attrs
      assert html_response(conn, 200) =~ "用户登录"
    end
  end
end
