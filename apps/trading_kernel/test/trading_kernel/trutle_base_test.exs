defmodule TradingKernel.TurtleBaseTest do
  use ExUnit.Case
  use TradingKernel.Sample

  describe "turtle base" do
    alias TradingKernel.TurtleBase

    test "n" do
      n = TurtleBase.n(@stock_results)
      assert Decimal.to_string(n) == "1.357340054285142186734116083"
    end
  end
end
