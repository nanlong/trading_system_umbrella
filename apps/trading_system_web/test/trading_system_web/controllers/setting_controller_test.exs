defmodule TradingSystem.Web.SettingControllerTest do
  use TradingSystem.Web.ConnCase

  alias TradingSystem.Accounts

  @user_attrs %{email: "test@qushi.pro", password: "123456", password_confirmation: "123456"}

  def user_login(%{conn: conn}) do
    Accounts.create_user(@user_attrs)
    conn = post conn, session_path(conn, :create), session: @user_attrs
    {:ok, conn: conn}
  end

  describe "index" do
    setup [:user_login]

    test "redirect", %{conn: conn} do
      conn = get conn, setting_path(conn, :index)
      assert redirected_to(conn) == setting_path(conn, :show, "config")
    end
  end

  describe "show setting" do
    setup [:user_login]

    test "show page profile", %{conn: conn} do
      conn = get conn, setting_path(conn, :show, "profile")
      assert html_response(conn, 200) =~ "趋势跟踪系统"
    end

    test "show page config", %{conn: conn} do
      conn = get conn, setting_path(conn, :show, "config")
      assert html_response(conn, 200) =~ "趋势跟踪系统"
    end
  end

  describe "update setting" do
    setup [:user_login]

    @profile_valid_attrs %{nickname: "test11"}
    @profile_invalid_attrs %{nickname: nil}
    @password_valid_attrs %{old_password: "123456", password: "xxxxxx", password_confirmation: "xxxxxx"}
    @config_valid_attrs %{account: 500000}

    test "update profile with valid attrs", %{conn: conn} do
      conn = put conn, setting_path(conn, :update, "profile"), user: @profile_valid_attrs
      assert redirected_to(conn) == setting_path(conn, :show, "profile")
    end

    test "update profile with invalid attrs", %{conn: conn} do
      conn = put conn, setting_path(conn, :update, "profile"), user: @profile_invalid_attrs
      assert html_response(conn, 200) =~ "不能为空"
    end

    test "update password with valid attrs", %{conn: conn} do
      conn = put conn, setting_path(conn, :update, "password"), user: @password_valid_attrs
      assert redirected_to(conn) == setting_path(conn, :show, "profile")
    end

    test "update config with valid attrs", %{conn: conn} do
      conn = put conn, setting_path(conn, :update, "config"), config: @config_valid_attrs
      assert redirected_to(conn) == setting_path(conn, :show, "config")
    end
  end

end
