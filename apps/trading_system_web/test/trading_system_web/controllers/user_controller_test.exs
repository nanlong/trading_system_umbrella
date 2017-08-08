defmodule TradingSystem.Web.UserControllerTest do
  use TradingSystem.Web.ConnCase

  @create_attrs %{email: "test@qushi.pro", password: "123456", password_confirmation: "123456"}
  @invalid_attrs %{email: nil, password: nil, password_confirmation: nil}

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get conn, user_path(conn, :new)
      assert html_response(conn, 200) =~ "用户注册"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @create_attrs
      assert redirected_to(conn) == page_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @invalid_attrs
      assert html_response(conn, 200) =~ "用户注册"
    end
  end

  # def fixture(:user) do
  #   {:ok, user} = Accounts.create_user(@create_attrs)
  #   user
  # end

  # defp create_user(_) do
  #   user = fixture(:user)
  #   {:ok, user: user}
  # end

  # describe "edit user" do
  #   setup [:create_user]

  #   test "renders form for editing chosen user", %{conn: conn, user: user} do
  #     conn = get conn, user_path(conn, :edit, user)
  #     assert html_response(conn, 200) =~ "Edit User"
  #   end
  # end
end
