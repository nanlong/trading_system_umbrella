defmodule TradingKernelTest do
  use ExUnit.Case
  use TradingKernel.Sample

  doctest TradingKernel

  describe "trading kernel" do
    alias TradingKernel

    test "n" do
      n = TradingKernel.n(@stock_results)
      assert Decimal.to_string(n) == "1.357340054285142186734116083"
    end
  end
end
