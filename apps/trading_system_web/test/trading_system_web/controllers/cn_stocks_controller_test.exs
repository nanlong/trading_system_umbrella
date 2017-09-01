defmodule TradingSystem.Web.CNStocksControllerTest do
  use TradingSystem.Web.ConnCase

  # alias TradingSystem.Markets

  # @create_attrs %{}
  # @update_attrs %{}
  # @invalid_attrs %{}

  # def fixture(:cn_stocks) do
  #   {:ok, cn_stocks} = Markets.create_cn_stocks(@create_attrs)
  #   cn_stocks
  # end

  # describe "index" do
  #   test "lists all cn_stocks", %{conn: conn} do
  #     conn = get conn, cn_stocks_path(conn, :index)
  #     assert html_response(conn, 200) =~ "Listing Cn stocks"
  #   end
  # end

  # describe "new cn_stocks" do
  #   test "renders form", %{conn: conn} do
  #     conn = get conn, cn_stocks_path(conn, :new)
  #     assert html_response(conn, 200) =~ "New Cn stocks"
  #   end
  # end

  # describe "create cn_stocks" do
  #   test "redirects to show when data is valid", %{conn: conn} do
  #     conn = post conn, cn_stocks_path(conn, :create), cn_stocks: @create_attrs

  #     assert %{id: id} = redirected_params(conn)
  #     assert redirected_to(conn) == cn_stocks_path(conn, :show, id)

  #     conn = get conn, cn_stocks_path(conn, :show, id)
  #     assert html_response(conn, 200) =~ "Show Cn stocks"
  #   end

  #   test "renders errors when data is invalid", %{conn: conn} do
  #     conn = post conn, cn_stocks_path(conn, :create), cn_stocks: @invalid_attrs
  #     assert html_response(conn, 200) =~ "New Cn stocks"
  #   end
  # end

  # describe "edit cn_stocks" do
  #   setup [:create_cn_stocks]

  #   test "renders form for editing chosen cn_stocks", %{conn: conn, cn_stocks: cn_stocks} do
  #     conn = get conn, cn_stocks_path(conn, :edit, cn_stocks)
  #     assert html_response(conn, 200) =~ "Edit Cn stocks"
  #   end
  # end

  # describe "update cn_stocks" do
  #   setup [:create_cn_stocks]

  #   test "redirects when data is valid", %{conn: conn, cn_stocks: cn_stocks} do
  #     conn = put conn, cn_stocks_path(conn, :update, cn_stocks), cn_stocks: @update_attrs
  #     assert redirected_to(conn) == cn_stocks_path(conn, :show, cn_stocks)

  #     conn = get conn, cn_stocks_path(conn, :show, cn_stocks)
  #     assert html_response(conn, 200)
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, cn_stocks: cn_stocks} do
  #     conn = put conn, cn_stocks_path(conn, :update, cn_stocks), cn_stocks: @invalid_attrs
  #     assert html_response(conn, 200) =~ "Edit Cn stocks"
  #   end
  # end

  # describe "delete cn_stocks" do
  #   setup [:create_cn_stocks]

  #   test "deletes chosen cn_stocks", %{conn: conn, cn_stocks: cn_stocks} do
  #     conn = delete conn, cn_stocks_path(conn, :delete, cn_stocks)
  #     assert redirected_to(conn) == cn_stocks_path(conn, :index)
  #     assert_error_sent 404, fn ->
  #       get conn, cn_stocks_path(conn, :show, cn_stocks)
  #     end
  #   end
  # end

  # defp create_cn_stocks(_) do
  #   cn_stocks = fixture(:cn_stocks)
  #   {:ok, cn_stocks: cn_stocks}
  # end
end
