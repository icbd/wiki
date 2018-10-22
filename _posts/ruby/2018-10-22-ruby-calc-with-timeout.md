---
layout: post
title:  业务逻辑中超时的实现  
date:   2018-10-22
categories: Ruby
---

TCP 连接等耗时操作都有timeout参数用来设置超时, 如果我们自己写一个计算也需要超时检查的话, 可以借助线程超时检查来完成.

对于 Thread, 当它被创建的时候就已经运行起来了, `join` 的作用是在主线程上等待它的完成.

```
join → thr
join(limit) → thr


1. 主线程挂起等待子线程运行完成.

2. 子线程不会退出, 直到达到时间限制.

3. 如果超时返回nil, 否则返回 `thr` .

4. 当主程序退出时, 会杀死所有没有 `join` 的线程.

5. If thr had previously raised an exception and the ::abort_on_exception or $DEBUG flags are not set, (so the exception has not yet been processed), it will be processed at this time.

```

## DEMO one

```ruby

# 用来接收结果
calc_result = nil
# 超级费时的处理
calc_thread = Thread.new do
  sleep(2)

  calc_result = 999
end

# 最多等待 500 ms
time_out = 0.500
if calc_thread.join(time_out).nil?
  puts "expired"
else
  puts calc_result
end

```

## 计算 fibonacci

`thread.join(time_out)` 可以看作为耗时操作, 最多等待 `time_out` 秒.
可以利用这个特点, 来实现 JavaScript 中 `setInterval` 的效果:


> main.rb

```ruby

def fibonacci(value)
  return value if value.zero? || value == 1
  fibonacci(value - 1) + fibonacci(value - 2)
end

def calc_fibonacci_with_timeout(value, time_out = nil)
  result = nil
  thread = Thread.new do
    result = fibonacci(value)
  end

  if time_out.nil?
    # 不限时
    thread.join
  else
    true until (print '.'; thread.join(time_out))
  end

  result
end

num = ARGV.shift.to_i
num = 10 if num <= 0
num.times do |i|
  value = i + 1
  puts "fib(#{value}):\t\t #{calc_fibonacci_with_timeout(value, 0.1)}"
end

```

> $ ruby main.rb 40

```text

$ ruby main.rb 40
.fib(1):		 1
.fib(2):		 1
.fib(3):		 2
.fib(4):		 3
.fib(5):		 5
.fib(6):		 8
.fib(7):		 13
.fib(8):		 21
.fib(9):		 34
.fib(10):		 55
.fib(11):		 89
.fib(12):		 144
.fib(13):		 233
.fib(14):		 377
.fib(15):		 610
.fib(16):		 987
.fib(17):		 1597
.fib(18):		 2584
.fib(19):		 4181
.fib(20):		 6765
.fib(21):		 10946
.fib(22):		 17711
.fib(23):		 28657
.fib(24):		 46368
.fib(25):		 75025
.fib(26):		 121393
.fib(27):		 196418
.fib(28):		 317811
.fib(29):		 514229
..fib(30):		 832040
..fib(31):		 1346269
...fib(32):		 2178309
.....fib(33):		 3524578
.......fib(34):		 5702887
............fib(35):		 9227465
.................fib(36):		 14930352
...........................fib(37):		 24157817
..........................................................fib(38):		 39088169
...................................................................................fib(39):		 63245986
..................................................................................................................................fib(40):		 102334155

```

(每个点代表100ms的计算耗时)

## 使用 Timeout.timeout

标准库中提供了 `timeout`, 也是用线程实现, 不过是借助 sleep .

```ruby
require 'timeout'

result = nil
begin
  Timeout.timeout(1) {
    sleep 2

    result = 999
  }
rescue Timeout::Error => e
  puts "timeout..."
end

puts "main. result:#{result}"

```