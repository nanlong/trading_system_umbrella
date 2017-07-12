defmodule TradingKernel do
  @moduledoc """
  Documentation for TradingKernel.
  """
  alias TradingSystem.Stocks

  def n(dailyk) do
    pre_status = Stocks.get_pre_stock_state(dailyk)

    if pre_status do
      %{
        pre_close_price: pcp, 
        highest_price: hp, 
        lowest_price: lp
      } = dailyk

      TradingKernel.Base.atr(pre_status.n, TradingKernel.Base.tr(pcp, hp, lp), 20)
    else
      history = Stocks.history_stock_dailyk(dailyk)
      TradingKernel.Turtle.n(history, 20)
    end
    |> Decimal.round(2)
  end

  def donchian_channel(dailyk, duration) do
    history = Stocks.history_stock_dailyk(dailyk, duration)
    high = TradingKernel.DonchianChannel.max_highest_price(history)
    low = TradingKernel.DonchianChannel.min_lowest_price(history)
    avg = TradingKernel.DonchianChannel.mid_price(high, low) |> Decimal.round(2)
    
    %{high: high, avg: avg, low: low}
  end

  def avg_50_gt_300?(dailyk) do
    history = Stocks.history_stock_dailyk(dailyk, 300)
    case TradingKernel.TrendPortfolioFilter.execute(history) do
      :long -> true
      :nothing -> false
      :short -> false
      _  -> false
    end
  end
end
