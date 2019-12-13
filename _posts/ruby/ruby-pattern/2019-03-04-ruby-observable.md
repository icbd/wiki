---
layout: post
title:  Ruby Observable Pattern  
date:   2019-03-04
categories: Ruby  Pattern
---

[http://ruby-doc.org/stdlib-2.6.1/libdoc/observer/rdoc/Observable.html](http://ruby-doc.org/stdlib-2.6.1/libdoc/observer/rdoc/Observable.html)

## Observable 观察者

观察者模式也称作发布/订阅模式, 它提供一种简单的机制, 在它状态发生变化时来通知一组第三方资源. 

## 机制

被观察者的类引入 `Observable` 模块, 该模块提供了管理相关观察者对象的方法. 

要求可观察的对象: 

 * 当变化发生后, 使用 `#changed` 方法来声明变化已发生
 * 调用 `#notify_observers` 方法传递通知的参数
 
观察者使用 `add_observer` 来订阅更新. 
更新发生时, 被观察者使用 `notify_observers` 来触发通知, 观察者默认使用 `update` 来接受更新参数.

## 实例

以下示例很好地演示了这一点. 一个 `Ticker` 运行之后, 不停地周期性拉取 "APPL" 的股价.
`Warner` 是一个股价的通用观察者, 当股价低于预设价, `WarnLow` 会打印警报, 当股价高于预设价, `WarnHigh` 会打印警报.
 
需要注意的是, 发布者与订阅者(被观察者和观察者)之间的合约不是显示的, 也不是强制执行的.
`Ticker` 发布时间和价格, warners 接受到这个通知. 如果你不确定合约的正确性, 再没其他的警告通知了.


```ruby
require 'observer'

# 模拟 API Client
class PriceAPI
  def self.fetch(stock_code:)
    sleep 0.010
    60 + rand(80)
  end
end

# 定期更新股价, 被观察者
class Ticker
  include Observable

  def initialize(stock_code:)
    @stock_code = stock_code
  end

  def run
    # 股价初始化
    last_price = nil

    loop do
      current_price = PriceAPI.fetch(stock_code: @stock_code)
      print "Current price: #{current_price}\n"
      if current_price != last_price
        changed and notify_observers(time: Time.now, price: current_price)
      end
      last_price = current_price

      sleep 0.5
    end
  end
end

# 对 Ticker 的观察者的抽象类
class Warner
  def initialize(observed_object:, price_limit:)
    @price_limit = price_limit
    observed_object.add_observer(self)
  end
end

# 低股价警报
class WarnerLow < Warner
  def update(time:, price:)
    if price < @price_limit
      print "--- #{time.to_s}: Price below #@limit: #{price}\n"
    end
  end
end

# 高股价警报
class WarnHigh < Warner
  def update(time:, price:)
    if price > @price_limit
      print "+++ #{time.to_s}: Price above #@limit: #{price}\n"
    end
  end
end

ticker = Ticker.new(stock_code: 'APPL')
WarnerLow.new(observed_object: ticker, price_limit: 80)
WarnHigh.new(observed_object: ticker, price_limit: 120)
ticker.run

```

## Output Demo

```text
Current price: 72
--- 2019-03-04 15:08:23 +0800: Price below : 72
Current price: 101
Current price: 117
Current price: 72
--- 2019-03-04 15:08:25 +0800: Price below : 72
Current price: 88
Current price: 97
Current price: 83
```
