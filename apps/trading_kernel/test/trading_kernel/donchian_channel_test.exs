defmodule TradingKernel.DonchianChannelTest do
  use ExUnit.Case
  use TradingKernel.Sample

  doctest TradingKernel.DonchianChannel
  
  describe "donchian channel" do
    alias TradingKernel.DonchianChannel

    test "execute" do
      resp = DonchianChannel.execute(@stock_results, 10)
      assert length(resp) == 86
    end

    test "system one" do
      resp = DonchianChannel.system(:one, @stock_results)
      assert length(resp) == 76
    end

    test "system two" do
      resp = DonchianChannel.system(:two, @stock_results)
      assert length(resp) == 36
    end
  end
end