---
layout: post
title:  Ruby 自定义类宏  
date:   2018-08-12
categories: Ruby
---

> 改编自元编程第6章

```ruby
module CheckedAttributes
  # 当 CheckedAttributes 被 include 的时候调用此钩子.
  # base 为 include CheckedAttributes 的类.
  def self.included(base)
    # 将 ClassMethods extend 到 base 类上,
    # 即, 将 ClassMethods 的方法添加为 base 的类方法.
    base.extend ClassMethods
  end

  module ClassMethods
    # attr_checked 被添加到 base类 上, 作为类方法调用
    # 此时的 self 为 base
    def attr_checked(attribute, &validation)
      # 强制要求校验 block
      raise "attr_checked need block" unless validation

      # get 方法:
      # 在 base 内定义新方法, 即 base 的实例方法
      define_method "#{attribute}" do
        # 此时的 self 为 base 的某实例对象
        instance_variable_get "@#{attribute}"
      end

      # set 方法:
      # 先校验再设置新值.
      define_method "#{attribute}=" do |value|
        raise "Invalid attribute" unless validation.call(value)
        instance_variable_set "@#{attribute}", value
      end
    end

  end
end
```

```ruby
require 'test/unit'
require './checked_attributes'

class Person
  include CheckedAttributes

  attr_checked :age do |v|
    v.to_i >= 18
  end

end


class TestCheckedAttribute < Test::Unit::TestCase
  def setup
    @bob = Person.new
  end

  def test_accepts_valid_values
    @bob.age = 20
    assert_equal 20, @bob.age
  end

  def test_refuses_nil_values
    assert_raises RuntimeError, "Invalid attribute" do
      @bob.age = nil
    end
  end

  def test_refuses_invalid_values
    assert_raises RuntimeError, "Invalid attribute" do
      @bob.age = 12
    end
  end

end


require 'test/unit/ui/console/testrunner'
Test::Unit::UI::Console::TestRunner.run(TestCheckedAttribute)

```