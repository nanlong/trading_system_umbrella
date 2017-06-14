defmodule TradingKernelTest do
  use ExUnit.Case
  doctest TradingKernel
  doctest TradingKernel.Base
  doctest TradingKernel.DonchianChannel

  test "the truth" do
    assert 1 + 1 == 2
  end
end
