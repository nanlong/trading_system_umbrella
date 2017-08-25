defmodule TradingSystem.Web.HKStocksControllerTest do
  use TradingSystem.Web.ConnCase

  alias TradingSystem.Markets

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:hk_stocks) do
    {:ok, hk_stocks} = Markets.create_hk_stocks(@create_attrs)
    hk_stocks
  end

  describe "index" do
    test "lists all hk_stocks", %{conn: conn} do
      conn = get conn, hk_stocks_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Hk stocks"
    end
  end

  describe "new hk_stocks" do
    test "renders form", %{conn: conn} do
      conn = get conn, hk_stocks_path(conn, :new)
      assert html_response(conn, 200) =~ "New Hk stocks"
    end
  end

  describe "create hk_stocks" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, hk_stocks_path(conn, :create), hk_stocks: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == hk_stocks_path(conn, :show, id)

      conn = get conn, hk_stocks_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Hk stocks"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, hk_stocks_path(conn, :create), hk_stocks: @invalid_attrs
      assert html_response(conn, 200) =~ "New Hk stocks"
    end
  end

  describe "edit hk_stocks" do
    setup [:create_hk_stocks]

    test "renders form for editing chosen hk_stocks", %{conn: conn, hk_stocks: hk_stocks} do
      conn = get conn, hk_stocks_path(conn, :edit, hk_stocks)
      assert html_response(conn, 200) =~ "Edit Hk stocks"
    end
  end

  describe "update hk_stocks" do
    setup [:create_hk_stocks]

    test "redirects when data is valid", %{conn: conn, hk_stocks: hk_stocks} do
      conn = put conn, hk_stocks_path(conn, :update, hk_stocks), hk_stocks: @update_attrs
      assert redirected_to(conn) == hk_stocks_path(conn, :show, hk_stocks)

      conn = get conn, hk_stocks_path(conn, :show, hk_stocks)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, hk_stocks: hk_stocks} do
      conn = put conn, hk_stocks_path(conn, :update, hk_stocks), hk_stocks: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Hk stocks"
    end
  end

  describe "delete hk_stocks" do
    setup [:create_hk_stocks]

    test "deletes chosen hk_stocks", %{conn: conn, hk_stocks: hk_stocks} do
      conn = delete conn, hk_stocks_path(conn, :delete, hk_stocks)
      assert redirected_to(conn) == hk_stocks_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, hk_stocks_path(conn, :show, hk_stocks)
      end
    end
  end

  defp create_hk_stocks(_) do
    hk_stocks = fixture(:hk_stocks)
    {:ok, hk_stocks: hk_stocks}
  end
end
