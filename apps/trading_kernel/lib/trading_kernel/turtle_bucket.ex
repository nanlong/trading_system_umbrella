defmodule TradingKernel.TurtleBucket do
  @moduledoc false
  
  @doc """
  创建数据
  """
  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  获取值
  """
  @spec get(map, atom) :: map
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  更新值
  """
  @spec put(map, atom, any) :: map
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end
end