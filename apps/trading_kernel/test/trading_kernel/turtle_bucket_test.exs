defmodule TradingKernel.TurtleBucketTest do
  use ExUnit.Case, async: true
  
  describe "turtle bucket" do
    alias TradingKernel.TurtleBucket

    test "stores values by key" do
      assert TurtleBucket.get(:symbol) == nil

      TurtleBucket.put(:symbol, "FB")
      assert TurtleBucket.get(:symbol) == "FB"

      assert TurtleBucket.state() == %TradingKernel.TurtleState{account: nil, breakout: nil,
             donchian: nil, history: nil, min_history: nil, n: nil, status: nil,
             symbol: "FB", today: nil, unit: nil}
    end
  end
end
