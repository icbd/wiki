---
layout: post
title:  ActiveRecord::Rollback
date:   2019-05-20
categories: Rails
---

# Reference

[https://api.rubyonrails.org/classes/ActiveRecord/Rollback.html](https://api.rubyonrails.org/classes/ActiveRecord/Rollback.html)

[http://bysxiang.com/articles/70](http://bysxiang.com/articles/70)

# Cases

```text
rails --version
Rails 6.0.0.rc1
```

## 单层事务内的普通异常

```ruby

class User < ApplicationRecord
  def transaction_test
    update(attr1: nil, attr2: nil, attr3: nil, attr4: nil)
    p self

    begin
      transaction do
        update(attr1: "ATTR_ONE")
        raise StandardError, '普通异常'
      end
    rescue => e
      p 'rescue>>>'
      p "捕获异常: #{e}"
    ensure
      p 'ensure>>>'
      p reload
    end
  end
end


```

事务被回滚, 继续向外抛异常.

```text

2.6.0 :004 > User.last.transaction_test
   (0.5ms)  SELECT sqlite_version(*)
  User Load (0.1ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT ?  [["LIMIT", 1]]
#<User id: 1, attr1: nil, attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 02:37:52">
   (0.1ms)  begin transaction
  User Update (0.5ms)  UPDATE "users" SET "attr1" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr1", "ATTR_ONE"], ["updated_at", "2019-05-21 03:35:03.740430"], ["id", 1]]
   (0.4ms)  rollback transaction
"rescue>>>"
"捕获异常: 普通异常"
"ensure>>>"
  User Load (0.1ms)  SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
#<User id: 1, attr1: nil, attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 02:37:52">
 => "捕获异常: 普通异常" 

```

## 单层事务内的手动回滚异常

```ruby

class User < ApplicationRecord
  def transaction_test
    update(attr1: nil, attr2: nil, attr3: nil, attr4: nil)
    p self

    begin
      transaction do
        update(attr1: "ATTR_ONE")
        raise ActiveRecord::Rollback, '手动回滚异常'
      end
    rescue => e
      p 'rescue>>>'
      p "捕获异常: #{e}"
    ensure
      p 'ensure>>>'
      p reload
    end
  end
end

```

事务被回滚, `ActiveRecord::Rollback` 异常被吞.

```text
2.6.0 :013 > User.last.transaction_test
   (0.1ms)  SELECT sqlite_version(*)
  User Load (0.1ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT ?  [["LIMIT", 1]]
#<User id: 1, attr1: nil, attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 02:37:52">
   (0.1ms)  begin transaction
  User Update (0.4ms)  UPDATE "users" SET "attr1" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr1", "ATTR_ONE"], ["updated_at", "2019-05-21 03:36:19.574401"], ["id", 1]]
   (0.4ms)  rollback transaction
"ensure>>>"
  User Load (0.1ms)  SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
#<User id: 1, attr1: nil, attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 02:37:52">
 => nil 
```

## 多层事务内的普通异常

```ruby
class User < ApplicationRecord
  def transaction_test
    update(attr1: nil, attr2: nil, attr3: nil, attr4: nil)
    p self

    begin
      transaction do
        update(attr1: "ATTR_ONE")
        transaction do
          update(attr2: "ATTR_TWO")
          raise StandardError, '普通异常'
        end
      end
    rescue => e
      p 'rescue>>>'
      p "捕获异常: #{e}"
    ensure
      p 'ensure>>>'
      p reload
    end
  end
end

```

默认情况下, 会将内外两个事务合并成一个事务. 普通异常在外层被捕获, 并且继续向外抛异常.

```text
2.6.0 :019 > User.last.transaction_test
   (0.1ms)  SELECT sqlite_version(*)
  User Load (0.1ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT ?  [["LIMIT", 1]]
#<User id: 1, attr1: nil, attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 02:37:52">
   (0.1ms)  begin transaction
  User Update (0.4ms)  UPDATE "users" SET "attr1" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr1", "ATTR_ONE"], ["updated_at", "2019-05-21 03:46:39.205584"], ["id", 1]]
  User Update (0.1ms)  UPDATE "users" SET "attr2" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr2", "ATTR_TWO"], ["updated_at", "2019-05-21 03:46:39.207658"], ["id", 1]]
   (0.3ms)  rollback transaction
"rescue>>>"
"捕获异常: 普通异常"
"ensure>>>"
  User Load (0.8ms)  SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
#<User id: 1, attr1: nil, attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 02:37:52">
 => "捕获异常: 普通异常"
```

## 多层事务内的手动回滚异常

```ruby
class User < ApplicationRecord
  def transaction_test
    update(attr1: nil, attr2: nil, attr3: nil, attr4: nil)
    p self

    begin
      transaction do
        update(attr1: "ATTR_ONE")
        transaction do
          update(attr2: "ATTR_TWO")
          raise ActiveRecord::Rollback, '手动回滚异常'
        end
      end
    rescue => e
      p 'rescue>>>'
      p "捕获异常: #{e}"
    ensure
      p 'ensure>>>'
      p reload
    end
  end
end

```

多个事务被合并, ActiveRecord::Rollback 在内层事务抛出, 被事务 block 阻断, 没有传到外层事务, 导致外层没有捕获到任何异常. 

内层的 `ActiveRecord::Rollback` 实际上没有可回滚的事务了, 内层事务已经被合并到外层了. 

```text
2.6.0 :043 > User.last.transaction_test
   (0.1ms)  SELECT sqlite_version(*)
  User Load (0.2ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT ?  [["LIMIT", 1]]
#<User id: 1, attr1: nil, attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 03:51:31">
   (0.1ms)  begin transaction
  User Update (0.4ms)  UPDATE "users" SET "attr1" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr1", "ATTR_ONE"], ["updated_at", "2019-05-21 03:53:26.407089"], ["id", 1]]
  User Update (0.1ms)  UPDATE "users" SET "attr2" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr2", "ATTR_TWO"], ["updated_at", "2019-05-21 03:53:26.408373"], ["id", 1]]
   (0.8ms)  commit transaction
"ensure>>>"
  User Load (0.2ms)  SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
#<User id: 1, attr1: "ATTR_ONE", attr2: "ATTR_TWO", attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 03:53:26">
 => nil 
```

# requires_new 选项

## 单层事务

对于单层事务, `requires_new` 并没有什么不同:

```ruby
class User < ApplicationRecord
  def transaction_test
    update(attr1: 'attr1', attr2: nil, attr3: nil, attr4: nil)
    p self
    p "---begin---"
    begin
      transaction(requires_new: true) do
        update(attr1: "ATTR_ONE")
      end
    rescue => e
      p 'rescue>>>'
      p "捕获异常: #{e}"
    ensure
      p 'ensure>>>'
      p reload
    end
  end
end


```

```text
2.6.0 :047 > reload!;User.last.transaction_test
Reloading...
   (0.1ms)  SELECT sqlite_version(*)
  User Load (0.1ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT ?  [["LIMIT", 1]]
   (0.0ms)  begin transaction
  User Update (0.6ms)  UPDATE "users" SET "attr1" = ?, "attr2" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr1", "attr1"], ["attr2", nil], ["updated_at", "2019-05-21 05:27:37.863917"], ["id", 1]]
   (1.2ms)  commit transaction
#<User id: 1, attr1: "attr1", attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 05:27:37">
"---begin---"
   (0.0ms)  begin transaction
  User Update (0.2ms)  UPDATE "users" SET "attr1" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr1", "ATTR_ONE"], ["updated_at", "2019-05-21 05:27:37.867315"], ["id", 1]]
   (0.8ms)  commit transaction
"ensure>>>"
  User Load (0.1ms)  SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
#<User id: 1, attr1: "ATTR_ONE", attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 05:27:37">
 => true 
2.6.0 :048 >
```

```ruby
class User < ApplicationRecord
  def transaction_test
    update(attr1: 'attr1', attr2: nil, attr3: nil, attr4: nil)
    p self
    p "---begin---"
    begin
      transaction(requires_new: true) do
        update(attr1: "ATTR_ONE")
        raise StandardError, '普通异常'
      end
    rescue => e
      p 'rescue>>>'
      p "捕获异常: #{e}"
    ensure
      p 'ensure>>>'
      p reload
    end
  end
end

```

```text
2.6.0 :048 > reload!;User.last.transaction_test
Reloading...
   (0.0ms)  SELECT sqlite_version(*)
  User Load (0.1ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT ?  [["LIMIT", 1]]
   (0.1ms)  begin transaction
  User Update (0.3ms)  UPDATE "users" SET "attr1" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr1", "attr1"], ["updated_at", "2019-05-21 05:34:14.872301"], ["id", 1]]
   (0.7ms)  commit transaction
#<User id: 1, attr1: "attr1", attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 05:34:14">
"---begin---"
   (0.0ms)  begin transaction
  User Update (0.3ms)  UPDATE "users" SET "attr1" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr1", "ATTR_ONE"], ["updated_at", "2019-05-21 05:34:14.881480"], ["id", 1]]
   (0.5ms)  rollback transaction
"rescue>>>"
"捕获异常: 普通异常"
"ensure>>>"
  User Load (0.2ms)  SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
#<User id: 1, attr1: "attr1", attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 05:34:14">
 => "捕获异常: 普通异常" 

```

```ruby
class User < ApplicationRecord
  def transaction_test
    update(attr1: 'attr1', attr2: nil, attr3: nil, attr4: nil)
    p self
    p "---begin---"
    begin
      transaction(requires_new: true) do
        update(attr1: "ATTR_ONE")
        raise ActiveRecord::Rollback, '手动回滚异常'
      end
    rescue => e
      p 'rescue>>>'
      p "捕获异常: #{e}"
    ensure
      p 'ensure>>>'
      p reload
    end
  end
end

```

```text
2.6.0 :049 > reload!;User.last.transaction_test
Reloading...
   (0.0ms)  SELECT sqlite_version(*)
  User Load (0.1ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT ?  [["LIMIT", 1]]
#<User id: 1, attr1: "attr1", attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 05:34:14">
"---begin---"
   (0.0ms)  begin transaction
  User Update (0.3ms)  UPDATE "users" SET "attr1" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr1", "ATTR_ONE"], ["updated_at", "2019-05-21 05:37:03.469884"], ["id", 1]]
   (0.5ms)  rollback transaction
"ensure>>>"
  User Load (0.2ms)  SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
#<User id: 1, attr1: "attr1", attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 05:34:14">
 => nil 

```

## 多层嵌套事务

```ruby
class User < ApplicationRecord
  def transaction_test
    update(attr1: 'attr1', attr2: nil, attr3: nil, attr4: nil)
    p self
    p "---begin---"
    begin
      transaction(requires_new: true) do
        update(attr1: "ATTR_ONE")
        transaction do
          update(attr2: "ATTR_TWO")
        end
      end
    rescue => e
      p 'rescue>>>'
      p "捕获异常: #{e}"
    ensure
      p 'ensure>>>'
      p reload
    end
  end
end

```

这个选项在外层事务中没有效果: 

```text
2.6.0 :065 > reload!;User.last.transaction_test
Reloading...
   (0.1ms)  SELECT sqlite_version(*)
  User Load (0.1ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT ?  [["LIMIT", 1]]
   (0.0ms)  begin transaction
  User Update (0.3ms)  UPDATE "users" SET "attr1" = ?, "attr2" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr1", "attr1"], ["attr2", nil], ["updated_at", "2019-05-21 05:44:05.478124"], ["id", 1]]
   (0.8ms)  commit transaction
#<User id: 1, attr1: "attr1", attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 05:44:05">
"---begin---"
   (0.0ms)  begin transaction
  User Update (0.4ms)  UPDATE "users" SET "attr1" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr1", "ATTR_ONE"], ["updated_at", "2019-05-21 05:44:05.480891"], ["id", 1]]
  User Update (0.1ms)  UPDATE "users" SET "attr2" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr2", "ATTR_TWO"], ["updated_at", "2019-05-21 05:44:05.482373"], ["id", 1]]
   (0.6ms)  commit transaction
"ensure>>>"
  User Load (0.1ms)  SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
#<User id: 1, attr1: "ATTR_ONE", attr2: "ATTR_TWO", attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 05:44:05">
 => true 

```

```ruby

class User < ApplicationRecord
  def transaction_test
    update(attr1: 'attr1', attr2: nil, attr3: nil, attr4: nil)
    p self
    p "---begin---"
    begin
      transaction do
        update(attr1: "ATTR_ONE")
        transaction(requires_new: true) do
          update(attr2: "ATTR_TWO")
        end
      end
    rescue => e
      p 'rescue>>>'
      p "捕获异常: #{e}"
    ensure
      p 'ensure>>>'
      p reload
    end
  end
end

```

在内层事务中使用 `requires_new: true` ,  会触发数据库的 `SAVEPOINT` 功能, 每一层为一个子事务. 

```text
2.6.0 :068 > reload!;User.last.transaction_test
Reloading...
   (0.0ms)  SELECT sqlite_version(*)
  User Load (0.1ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT ?  [["LIMIT", 1]]
   (0.0ms)  begin transaction
  User Update (0.4ms)  UPDATE "users" SET "attr1" = ?, "attr2" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr1", "attr1"], ["attr2", nil], ["updated_at", "2019-05-21 05:46:36.246354"], ["id", 1]]
   (1.0ms)  commit transaction
#<User id: 1, attr1: "attr1", attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 05:46:36">
"---begin---"
   (0.0ms)  begin transaction
  User Update (0.4ms)  UPDATE "users" SET "attr1" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr1", "ATTR_ONE"], ["updated_at", "2019-05-21 05:46:36.249353"], ["id", 1]]
   (0.0ms)  SAVEPOINT active_record_1
  User Update (0.1ms)  UPDATE "users" SET "attr2" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr2", "ATTR_TWO"], ["updated_at", "2019-05-21 05:46:36.250661"], ["id", 1]]
   (0.1ms)  RELEASE SAVEPOINT active_record_1
   (1.0ms)  commit transaction
"ensure>>>"
  User Load (0.1ms)  SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
#<User id: 1, attr1: "ATTR_ONE", attr2: "ATTR_TWO", attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 05:46:36">
 => true 
```

```ruby
class User < ApplicationRecord
  def transaction_test
    update(attr1: 'attr1', attr2: nil, attr3: nil, attr4: nil)
    p self
    p "---begin---"
    begin
      transaction do
        update(attr1: "ATTR_ONE")
        transaction(requires_new: true) do
          update(attr2: "ATTR_TWO")
          raise StandardError, '普通异常'
        end
      end
    rescue => e
      p 'rescue>>>'
      p "捕获异常: #{e}"
    ensure
      p 'ensure>>>'
      p reload
    end
  end
end

```

```text
2.6.0 :077 > reload!;User.last.transaction_test
Reloading...
   (0.0ms)  SELECT sqlite_version(*)
  User Load (0.1ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT ?  [["LIMIT", 1]]
   (0.0ms)  begin transaction
  User Update (0.3ms)  UPDATE "users" SET "attr1" = ?, "attr2" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr1", "attr1"], ["attr2", nil], ["updated_at", "2019-05-21 05:51:06.126923"], ["id", 1]]
   (0.6ms)  commit transaction
#<User id: 1, attr1: "attr1", attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 05:51:06">
"---begin---"
   (0.1ms)  begin transaction
  User Update (0.2ms)  UPDATE "users" SET "attr1" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr1", "ATTR_ONE"], ["updated_at", "2019-05-21 05:51:06.129439"], ["id", 1]]
   (0.0ms)  SAVEPOINT active_record_1
  User Update (0.1ms)  UPDATE "users" SET "attr2" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr2", "ATTR_TWO"], ["updated_at", "2019-05-21 05:51:06.130663"], ["id", 1]]
   (0.0ms)  ROLLBACK TO SAVEPOINT active_record_1
   (0.3ms)  rollback transaction
"rescue>>>"
"捕获异常: 普通异常"
"ensure>>>"
  User Load (0.2ms)  SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
#<User id: 1, attr1: "attr1", attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 05:51:06">
 => "捕获异常: 普通异常"
```

```ruby
class User < ApplicationRecord
  def transaction_test
    update(attr1: 'attr1', attr2: nil, attr3: nil, attr4: nil)
    p self
    p "---begin---"
    begin
      transaction do
        update(attr1: "ATTR_ONE")
        transaction(requires_new: true) do
          update(attr2: "ATTR_TWO")
          raise ActiveRecord::Rollback, '手动回滚异常'
        end
      end
    rescue => e
      p 'rescue>>>'
      p "捕获异常: #{e}"
    ensure
      p 'ensure>>>'
      p reload
    end
  end
end

```

```text
2.6.0 :081 > reload!;User.last.transaction_test
Reloading...
   (0.1ms)  SELECT sqlite_version(*)
  User Load (0.1ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT ?  [["LIMIT", 1]]
#<User id: 1, attr1: "attr1", attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 05:51:06">
"---begin---"
   (0.1ms)  begin transaction
  User Update (0.3ms)  UPDATE "users" SET "attr1" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr1", "ATTR_ONE"], ["updated_at", "2019-05-21 05:52:08.077374"], ["id", 1]]
   (0.0ms)  SAVEPOINT active_record_1
  User Update (0.1ms)  UPDATE "users" SET "attr2" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["attr2", "ATTR_TWO"], ["updated_at", "2019-05-21 05:52:08.078580"], ["id", 1]]
   (0.0ms)  ROLLBACK TO SAVEPOINT active_record_1
   (0.7ms)  commit transaction
"ensure>>>"
  User Load (0.1ms)  SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
#<User id: 1, attr1: "ATTR_ONE", attr2: nil, attr3: nil, attr4: nil, created_at: "2019-05-21 02:35:55", updated_at: "2019-05-21 05:52:08">
 => nil 

```

## 小结

`transaction` 嵌套, 默认会合并到最外层事务一起 commit . 

`transaction(requires_new: true)` 用在内层事务, 用来触发 `SAVEPOINT` .

`raise StandardError` 会穿越 `transaction` 的 block 一层一层向外抛异常;

`raise ActiveRecord::Rollback` 会被最内层的 `transaction` 截获, 只对内层的 `transaction` 回滚有效, 对外层的 `transaction` 无效.
