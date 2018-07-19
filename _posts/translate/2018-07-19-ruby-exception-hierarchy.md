---
layout: post
title:  Ruby Exception Hierarchy  
date:   2018-07-19
categories: Ruby
---

> 翻译自: [http://blog.honeybadger.io/understanding-the-ruby-exception-hierarchy/](http://blog.honeybadger.io/understanding-the-ruby-exception-hierarchy/)

Ruby 中异常也是类. 异常的继承由异常类的继承决定.

这里是 Ruby 2.1 标准库中的异常层次:

```
Exception
  NoMemoryError
  ScriptError
    LoadError
    NotImplementedError
    SyntaxError
  SecurityError
  SignalException
    Interrupt
  StandardError -- default for rescue
    ArgumentError
      UncaughtThrowError
    EncodingError
    FiberError
    IOError
      EOFError
    IndexError
      KeyError
      StopIteration
    LocalJumpError
    NameError
      NoMethodError
    RangeError
      FloatDomainError
    RegexpError
    RuntimeError -- default for raise
    SystemCallError
      Errno::*
    ThreadError
    TypeError
    ZeroDivisionError
  SystemExit
  SystemStackError
```

## 实际使用

把异常编排进类的继承树中, 这样可以让你更简单得使用同类的异常.

例如, 考虑这样的代码:

```ruby
begin
  do_something
rescue StandardError => e
end
```

这里不仅会捕获 StandardError, 还会捕获其他继承自 StandardError 的类. 通常这些异常就是你关心的.

在你自己的代码里, 你可以把常用的异常继承自一个单一异常基类:

```ruby
module MyLib

  class Error < StandardError
  end

  class TimeoutError < Error
  end

  class ConnectionError < Error
  end

end

...

begin
  do_something
rescue MyLib::Error => e
  # Rescues any of the exceptions defined above
end
```