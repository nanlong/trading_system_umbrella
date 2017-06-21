defmodule TradingKernel.TurtleBucketTest do
  use ExUnit.Case, async: true
  
  describe "turtle bucket" do
    alias TradingKernel.TurtleBucket

    setup do
      {:ok, bucket} = TurtleBucket.start_link()
      {:ok, bucket: bucket}
    end

    test "stores values by key", %{bucket: bucket} do
      assert TurtleBucket.get(bucket, "milk") == nil

      TurtleBucket.put(bucket, "milk", 3)
      assert TurtleBucket.get(bucket, "milk") == 3
    end
  end
end
