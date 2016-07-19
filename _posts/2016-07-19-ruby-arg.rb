---
layout: post
title:  ruby 函数传参小结
date:   2016-07-19
categories: Ruby
---

# ARGV 数组

注意传进来的参数都是String

```
# this is  arg.rb
p ARGV

=begin
$ ruby arg.rb 1 2 3
结果输出 =>
["1", "2", "3"]
=end
```

# 基本用法

```
def func(p1, p2)
  p1 + p2
end

ans = func(2, 3)
```

# 默认参数

```
def func(p1, p2, base=10000)
  base + p1 + p2
end

p func(2, 3)
p func(2, 3, 10)

=begin
结果输出 =>
10005
15
=end
```

# 参数解包

方法参数为基本形式,把数组当做参数传入.
在调用的时候进行参数解包, 将数组依次解开赋值给方法的参数.

```
def func(p1,p2,p3)
  p1+p2+p3
end

arr = [1,2,3]
p func(*arr)

=begin
结果输出 =>
6
=end
```

数组长度必须与方法参数个数一致, 否则抛异常: 参数个数不匹配.

```
def func(p1,p2,p3)
  p1+p2+p3
end

arr = [1,2,3,4]
p func(*arr)

=begin
:1:in `func': wrong number of arguments (given 4, expected 3) (ArgumentError)
	from /Users/cbd/Desktop/rubyt/arg.rb:6:in `<top (required)>'
	from -e:1:in `load'
	from -e:1:in `<main>'
=end
```

部分参数解包(1), 与普通参数混合使用

```
def func(base,*p)
  p.each do |i|
    base += i
  end

  return base
end

puts func(100, 1,2,3)

=begin
106
=end
```

部分参数解包(2), 与普通参数混合使用

```
def func(base,*p, msg)
  p.each do |i|
    base += i
  end

  p msg

  return base
end

puts func(100, 1,2,3, '部分参数解包(2)')

=begin
"部分参数解包(2)"
106
=end
```

> 特别注意, 在参数中最多只能出现一次样子为 *arg 的参数, 并且出现在最后或者中间, 即可以明确*arg匹配的位置.

# 参数解包 散列版

```
def func(**arg)
  arg.each do |k, v|
    puts "k::#{k}\t,\tv::#{v}"
  end
end

func(p1:123, p2:'hello')

=begin
k::p1	,	v::123
k::p2	,	v::hello
=end
```

# 命名参数(散列)

参数用散列的形式, 要求每个参数必须指定默认值.


```
def func(p1: 1, p2: 2)
  p1 + p2
end

puts func(p1: 100, p2: 200)
puts func(p1: 100)

=begin
300
102
=end
```

也可以把现成的散列传进去, 注意其key必须为Symbol类型

```
def func(p1: 1, p2: 2)
  p1 + p2
end

h = {
    :p1 => 100,
    :p2 => 200
}
h_err = {
    'p1' => 100,
    'p2' => 200
}
p func(h)
p func(h_err)

=begin
300
in `func': wrong number of arguments (given 1, expected 0) (ArgumentError)
	from /Users/cbd/Desktop/rubyt/arg.rb:14:in `<top (required)>'
	from -e:1:in `load'
	from -e:1:in `<main>'
=end
```

若使用了参数散列表中没有指定过的键值, 则会抛参数异常.

```
def func(p1: 1, p2: 2)
  p1 + p2
end

puts func(p1: 100, p2: 200, p3: 999)

=begin
in `func': unknown keyword: p3 (ArgumentError)
	from /Users/cbd/Desktop/rubyt/arg.rb:5:in `<top (required)>'
	from -e:1:in `load'
	from -e:1:in `<main>'
=end
```

处理上面这个情况, 可以把命名散列参数和散列参数解包混合使用

```
def func(p1: 1, p2: 2, **arg)
  puts p1 + p2
  arg.each do |k, v|
    puts "k::#{k}\t,\tv::#{v}"
  end
end

func(p1: 640, p2: 320, px: '像素')
func(p1: 640, px: '像素')
func(px: '像素')

=begin
960
k::px	,	v::像素
642
k::px	,	v::像素
3
k::px	,	v::像素
=end
```







