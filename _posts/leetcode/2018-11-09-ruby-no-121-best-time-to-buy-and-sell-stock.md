---
layout: post
title:  LeetCode Ruby No.121 best-time-to-buy-and-sell-stock  
date:   2018-11-09
categories: algorithm
---


# 暴力

> Timeout

```ruby

# @param {Integer[]} prices
# @return {Integer}
def max_profit(prices)

  # 初始化利润
  profit = 0
  len = prices.size

  (0...len).each do |buy_at|
    (buy_at + 1...len).each do |sell_at|
      temp_profit = prices[sell_at] - prices[buy_at]
      profit = temp_profit if temp_profit > profit
    end
  end

  profit
end

# p max_profit([7, 1, 5, 3, 6, 4])
# p max_profit([7, 6, 4, 3, 1])
 
```

# DP

```ruby

# @param {Integer[]} prices
# @return {Integer}
def max_profit(prices)

  # 初始化利润
  profit = 0
  buy_price = prices.shift
  prices.each do |price|
    if price < buy_price
      buy_price = price
    end

    temp_profit = price - buy_price
    if profit < temp_profit
      profit = temp_profit
    end
  end

  profit
end

# p max_profit([7, 1, 5, 3, 6, 4])
# p max_profit([7, 6, 4, 3, 1])

```