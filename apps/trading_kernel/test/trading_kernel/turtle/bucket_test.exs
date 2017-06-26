defmodule TradingKernel.Turtle.BucketTest do
  use ExUnit.Case, async: true
  
  describe "turtle bucket" do
    alias TradingKernel.Turtle.Bucket

    test "stores values by key" do
      assert Bucket.get(:symbol) == nil

      Bucket.put(:symbol, "FB")
      assert Bucket.get(:symbol) == "FB"

      assert Bucket.state() == %TradingKernel.Turtle.State{account: nil, breakout: nil,
             donchian: nil, history: nil, min_history: nil, n: nil,
             status_50_300: nil, symbol: "FB", today: nil, trading?: nil,
             unit: nil}

      assert Bucket.has_key?(:symbol)
    end
  end
end
