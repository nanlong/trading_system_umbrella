defmodule TradingKernel.TurtleBaseTest do
  use ExUnit.Case
  use TradingKernel.Sample
  doctest TradingKernel.Turtle

  describe "turtle base" do
    alias TradingKernel.Turtle

    test "n" do
      n = Turtle.n(@stock_results)
      assert Decimal.to_string(n) == "1.357340054285142186734116083"
    end
  end
end
