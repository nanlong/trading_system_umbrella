defmodule TradingKernel.TurtleBucketTest do
  use ExUnit.Case, async: true
  
  describe "turtle bucket" do
    alias TradingKernel.TurtleBucket

    setup do
      TurtleBucket.start_link()
      :ok
    end

    test "stores values by key" do
      assert TurtleBucket.get("milk") == nil

      TurtleBucket.put("milk", 3)
      assert TurtleBucket.get("milk") == 3
    end
  end
end
