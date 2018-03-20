---
layout: post
title:  Ruby中的extend与include
date:   2016-07-20
categories: Ruby
---

```
module Hello
  def hello_func
    'this is Hello#hello_func'
  end
end

module Hi
  def hi_func
    'this is Hi#hi_func'
  end
end


class MyClass
  include Hello
  extend Hi
end

me = MyClass.new
p MyClass::hi_func
p me.hello_func

```

代码说明地很清楚了, 但是还是不好记.

可以这想:

include是包含, 将module中的方法包到自己的方法查找数上面, 实例对象先找自己的方法, 找不到再找module中的.
extend是扩展, 类 把module中的方法拿来扩展自己的静态方法树, 可以通过类名直接调用类方法.