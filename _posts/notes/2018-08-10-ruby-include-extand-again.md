---
layout: post
title:  再论include和extend  
date:   2018-08-10
categories: Ruby
---

## include
将模块中的实例方法插入到类内, 作为类的实例方法.

C作为方法的接收者, 收下来后, 作为实例方法调用.

```ruby
module M
  def hi
    puts "M#hi"
  end
end

class C
  include M
end

C.new.hi
```

等效于:

```ruby
module M
  def hi
    puts "M#hi"
  end
end

class C; end

C.class_eval do
  include M
end

C.new.hi
```

## include
将模块中的实例方法插入到类的的单件类中, 作为类方法调用.

```ruby
module M
  def hi
    puts "M#hi"
  end
end

class C
  class << self
    include M
  end

end

C.hi
```

等效于:

```ruby
module M
  def hi
    puts "M#hi"
  end
end

class C; end

C.singleton_class.class_eval do
  include M
end

C.hi
```

还等效于: 

```ruby
module M
  def hi
    puts "M#hi"
  end
end

class C
  extend M
end

C.hi
```

对象负责存放数据, 对象的方法存在其单件类内, 或者对象的类内.

查找顺序是先找对象本身的单件类, 找不到就向上, 找类内的实例方法(实例对象的单件类的超类是该实例对象的类),
 还找不到就再向上沿着祖先链查找, 查找各个超类内的实例方法.

在这个过程中, 各个超类的单件类不会暴露任何信息.

`include` 和 `extend` 的方法, 都排在原有方法之后, 也就是说引入的方法不会覆盖原有的同名方法.