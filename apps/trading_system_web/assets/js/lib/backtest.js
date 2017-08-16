class Backtest {
  constructor(data, config) {
    this.data = data.slice(300, data.length)
    this.config = config
    this.current_tread = this.tread(data[data.length - 1])
    this.lineData = []
    this.position = {
      tread: '',
      amount: 0,
      unit: 0,
      price: 0,
      avgPrice: 0,
      addPositionPrice: 0,
      stopLossPrice: 0,
    }
  }

  run() {
    this.data.map(x => {
      if (this.position.amount == 0 && this.isCreatePosition(x)) {
        // 建仓
        this.createPosition(x)
      }
      else if (this.position.amount > 0 && this.position.amount < this.config.position && this.isAddPosition(x)) {
        // 加仓
        this.addPosition(x)
      }
      else if (this.position.amount > 0 && this.isClosePosition(x)) {
        // 平仓
        this.closePosition(x)
      }
      else if (this.position.amount > 0 && this.isStopLoss(x)) {
        // 止损
        this.stopLoss(x)
      }
    })

    return this.lineData
  }

  // 执行建仓
  createPosition(dataItem) {
    const {date, atr} = dataItem
    const price = this.breakPoint(dataItem)

    this.position = {
      tread: this.tread(dataItem),
      amount: 1,
      unit: 0,
      atr: atr,
      breakPrice: price,
      avgPrice: this.avgPrice(dataItem, price, atr, 1),
      addPositionPrice: this.bidPrice(dataItem, price, atr, 2),
      stopLossPrice: this.stopLossPrice(dataItem, price, atr, 1),
    }

    if (this.current_tread == this.position.tread) {
      this.lineData.push({
        action: "create",
        date: date,
        price: price,
      })
    }
  }

  // 执行加仓
  addPosition(dataItem) {
    const {tread, amount, unit, atr, breakPrice} = this.position
    const current_amount = amount + 1
    
    this.position = {
      tread: tread,
      amount: current_amount,
      unit: unit,
      atr: atr,
      breakPrice: breakPrice,
      avgPrice: this.avgPrice(dataItem, breakPrice, atr, current_amount),
      addPositionPrice: this.bidPrice(dataItem, breakPrice, atr, current_amount + 1),
      stopLossPrice: this.stopLossPrice(dataItem, breakPrice, atr, current_amount),
    }
  }

  // 执行平仓
  closePosition(dataItem) {
    if (this.current_tread == this.position.tread) {
      const {date} = dataItem
      const price = this.closePoint(dataItem)

      this.lineData.push({
        action: "close",
        date: date,
        price: price
      })
    }
    
    this.position = {
      tread: '',
      amount: 0,
      unit: 0,
      price: 0,
      avgPrice: 0,
      addPositionPrice: 0,
      stopLossPrice: 0,
    }    
  }

  // 执行止损
  stopLoss(dataItem) {
    if (this.current_tread == this.position.tread) {
      const {date} = dataItem
      const price = this.position.stopLossPrice

      this.lineData.push({
        action: "stop",
        date: date,
        price: price
      })
    }
    
    this.position = {
      tread: '',
      amount: 0,
      unit: 0,
      price: 0,
      avgPrice: 0,
      addPositionPrice: 0,
      stopLossPrice: 0,
    }
  }
  
  // 买入价
  bidPrice(dataItem, price, atr, position) {
    let num1 = price
    let num2 = atr * this.config.atr_add_step * (position - 1)

    if ((this.position.tread != '' && this.position.tread == 'bull') || this.isBull(dataItem)) {
      return num1 + num2
    }
    else {
      return num1 - num2
    }
  }

  // 平均价
  avgPrice(dataItem, price, atr, position) {
    if (position == 1) {
      return price
    }
    else {
      let positionSum = 0

      for (var i = 1; i < position; i++) {
        positionSum += i
      }

      let num1 = price * position
      let num2 = atr * this.config.atr_add_step * positionSum

      if ((this.position.tread != '' && this.position.tread == 'bull') || this.isBull(dataItem)) {
        return (num1 + num2) / position
      }
      else {
        return (num1 - num2) / position
      }
    }
  }

  // 止损价
  stopLossPrice(dataItem, price, atr, position) {
    let num1 = this.avgPrice(dataItem, price, atr, position)
    let num2 = atr * (this.config.atr_stop_step / position)

    if ((this.position.tread != '' && this.position.tread == 'bull') || this.isBull(dataItem)) {
      return num1 - num2
    }
    else {
      return num1 + num2
    }
  }
  
  // 交易方向
  tread(dataItem) {
    const {ma50, ma300} = dataItem
    return ma50 > ma300 ? 'bull' : 'bear'
  }

  // 是否做多
  isBull(dataItem) {
    return this.tread(dataItem) == 'bull'
  }

  // 是否建仓
  isCreatePosition(dataItem) {
    const price = this.breakPoint(dataItem)
    const {lowest, highest} = dataItem
    
    return lowest < price && price < highest
  }

  // 是否加仓
  isAddPosition(dataItem) {
    const price = this.position.addPositionPrice
    const {lowest, highest} = dataItem
    
    if (this.position.tread == 'bull') {
      return price < highest
    }
    else {
      return lowest < price
    }
  }

  // 是否平仓
  isClosePosition(dataItem) {
    const price = this.closePoint(dataItem)
    const {lowest, highest} = dataItem

    if (this.position.tread == 'bull') {
      return lowest < price
    }
    else {
      return price < highest
    }
  }

  // 是否止损
  isStopLoss(dataItem) {
    const price = this.position.stopLossPrice
    const {lowest, highest} = dataItem
    
    if (this.position.tread == 'bull') {
      return lowest < price
    }
    else {
      return price < highest
    }
  }

  // 计算突破点
  breakPoint(dataItem) {
    const {dcu20, dcu60, dcl20, dcl60} = dataItem

    if (this.isBull(dataItem)) {
      switch (this.config.create_days) {
        case 60: 
          return dcu60
        case 20: 
        default: 
          return dcu20
      }
    }
    else {
      switch (this.config.create_days) {
        case 60: 
          return dcl60
        case 20:
        default: 
          return dcl20
      }
    }
  }

  // 计算止盈点
  closePoint(dataItem) {
    const {dcl10, dcl20, dcu10, dcu20} = dataItem
    if (this.position.tread == 'bull') {
      switch (this.config.close_days) {
        case 20:
          return dcl20
        case 10:
        default:
          return dcl10
      }
    }
    else {
      switch (this.config.close_days) {
        case 20:
          return dcu20
        case 10:
        default:
          return dcu10
      }
    }
  }
}

export default Backtest