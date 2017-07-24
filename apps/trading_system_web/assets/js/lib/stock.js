function range(start, end) {
  return Array(end - start + 1).fill(0).map((v, i) => i + start)
}

function sum(start, end) {
  if (start > end) {
    return 0
  }
  else if (start == end) {
    return start
  }
  else {
    return range(start, end).reduce((pre, cur, _index, _arr) => pre + cur)
  }
}

function buy(buy_signal, atr, position) {
  return buy_signal + atr * 0.5 * (position - 1)
}

function buy_avg(buy_signal, atr, position) {
  return (buy_signal * position + atr * 0.5 * sum(1, position - 1)) / position
}

function stop_loss(buy_signal, atr, position) {
  return buy_avg(buy_signal, atr, position) - atr * 4 / position
}

export {buy, buy_avg, stop_loss}