---
layout: post
title:  记一次单表继承时的UUID生成的BUG
date:   2019-03-13
categories: Rails
---

> 基础模型

```ruby
class FapiaoFile < ApplicationRecord
  before_create :init_uuid
  
  private

  def init_uuid
    return if uuid.present?

    loop do
      self.uuid = SecureRandom.alphanumeric(20)
      self.class.exists?(uuid: uuid) ? next : break
    end
  end
end
```

> 具体模型

```ruby
class ElectroFapiaoFile < FapiaoFile
end

class BlueElectroFapiaoFile < ElectroFapiaoFile
end

class RedElectroFapiaoFile < ElectroFapiaoFile
end

```

这是一个典型的单表继承的情景( Single Table Inheritance ), 只不过通常只会用到一个层级, 这里出现了两个层级.

STI 会把类名存贮到 `type` 字段, 当 `FapiaoFile.find(obj.id)`, 会自动映射为 `type` 中存贮的类, 该可以对象可以正确相应:

  ```ruby
  FapiaoFile.find(obj.id).is_a?(BlueElectroFapiaoFile) # => true
  
  FapiaoFile.find(obj.id).is_a?(ElectroFapiaoFile) # => true
  
  ``` 

另外, 可以通过 `Base.inheritance_column` 来修改 `type` 为其他字段.

这一切看起来都很棒, 但是你有没有发现最开始的代码有什么问题?

没错, 问题就出现 `self.class`! 
如果用 `BlueElectroFapiaoFile.create` 来创建一个 `FapiaoFile`, `self.class` 是 `BlueElectroFapiaoFile`.

rails log 显示: 

```text
SELECT  1 AS one FROM "fapiao_files" WHERE "fapiao_files"."type" IN ('BlueElectroFapiaoFile') AND "fapiao_files"."uuid" = $1 LIMIT $2  [["uuid", "QmNZnHR6Om3ToRc7eVHK"], ["LIMIT", 1]]
```

很明显, 我们验证 `uuid` 唯一的时候不想加 `type` 条件, 正确的写法就是明确的写出来:

```ruby
FapiaoFile.exists?(uuid: uuid) ? next : break
```


### 由此扩展

由于 Rails 按需加载, 首次使用 `ElectroFapiaoFile` 的时候,  Rails 看不到 `BlueElectroFapiaoFile` 和 `RedElectroFapiaoFile`.

此时, `ElectroFapiaoFile.count` 对应的SQL为 :

```
SELECT COUNT(*) FROM "fapiao_files" WHERE "fapiao_files"."type" IN ('ElectroFapiaoFile')
```

使用 `require_dependency` 可以解决这个问题, 让Rails在加载 `ElectroFapiaoFile` 的时候就知道
 `BlueElectroFapiaoFile` 和 `RedElectroFapiaoFile` 的存在. 
 因此, 明确依赖关系后, 任何时候调用 `ElectroFapiaoFile.count` 对应的SQL都为:
 
```
SELECT COUNT(*) FROM "fapiao_files" WHERE "fapiao_files"."type" 

IN ('ElectroFapiaoFile', 'BlueElectroFapiaoFile', 'RedElectroFapiaoFile')
```

## reference

[https://api.rubyonrails.org/classes/ActiveRecord/Inheritance.html](https://api.rubyonrails.org/classes/ActiveRecord/Inheritance.html)
