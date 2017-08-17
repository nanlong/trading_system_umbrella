defmodule TradingSystem.Web.CalculatorControllerTest do
  use TradingSystem.Web.ConnCase

  alias TradingSystem.Toolbox

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:calculator) do
    {:ok, calculator} = Toolbox.create_calculator(@create_attrs)
    calculator
  end

  describe "index" do
    test "lists all calculator", %{conn: conn} do
      conn = get conn, calculator_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Calculator"
    end
  end

  describe "new calculator" do
    test "renders form", %{conn: conn} do
      conn = get conn, calculator_path(conn, :new)
      assert html_response(conn, 200) =~ "New Calculator"
    end
  end

  describe "create calculator" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, calculator_path(conn, :create), calculator: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == calculator_path(conn, :show, id)

      conn = get conn, calculator_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Calculator"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, calculator_path(conn, :create), calculator: @invalid_attrs
      assert html_response(conn, 200) =~ "New Calculator"
    end
  end

  describe "edit calculator" do
    setup [:create_calculator]

    test "renders form for editing chosen calculator", %{conn: conn, calculator: calculator} do
      conn = get conn, calculator_path(conn, :edit, calculator)
      assert html_response(conn, 200) =~ "Edit Calculator"
    end
  end

  describe "update calculator" do
    setup [:create_calculator]

    test "redirects when data is valid", %{conn: conn, calculator: calculator} do
      conn = put conn, calculator_path(conn, :update, calculator), calculator: @update_attrs
      assert redirected_to(conn) == calculator_path(conn, :show, calculator)

      conn = get conn, calculator_path(conn, :show, calculator)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, calculator: calculator} do
      conn = put conn, calculator_path(conn, :update, calculator), calculator: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Calculator"
    end
  end

  describe "delete calculator" do
    setup [:create_calculator]

    test "deletes chosen calculator", %{conn: conn, calculator: calculator} do
      conn = delete conn, calculator_path(conn, :delete, calculator)
      assert redirected_to(conn) == calculator_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, calculator_path(conn, :show, calculator)
      end
    end
  end

  defp create_calculator(_) do
    calculator = fixture(:calculator)
    {:ok, calculator: calculator}
  end
end
