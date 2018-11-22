---
layout: post
title:  Rails lock_version 乐观锁  
date:   2018-11-22
categories: Rails
---

# 什么是乐观锁

乐观锁允许多个用户访问同一条的记录以进行编辑, 假定数据冲突最小. 
他检查其他程序是否对这条已读到的记录有修改, 如果该记录已经被修改了, 则放弃本次修改, 并且抛出异常 `ActiveRecord::StaleObjectError` .

查看 `ActiveRecord::Locking::Pessimistic` 以获取替代方案.

# 使用

如果表上存在 `lock_version` 字段的话, `Active Record` 就提供乐观锁支持.
每次更新记录的时候都会对 `lock_version` 字段加一.
查询记录两次实例化为两个变量, 如果第一个变量发生了更新, 那么锁会确保后一个抛 `StaleObjectError`.

```ruby

p1 = Person.find(1)
p2 = Person.find(1)

p1.first_name = "Michael"
p1.save

p2.first_name = "should fail"
p2.save # Raises an ActiveRecord::StaleObjectError

```

当对象被销毁时, 乐观锁还会检查数据是否失效. 比如:

```ruby

p1 = Person.find(1)
p2 = Person.find(1)

p1.first_name = "Michael"
p1.save

p2.destroy # Raises an ActiveRecord::StaleObjectError

```

由程序员负责通过捕获异常来处理冲突, 包括其他的事务回滚/合并, 获取其他业务逻辑.

这种锁机制在单个Ruby进程中起效. 如果要让他在分布式的环境中起效, 推荐的方法是将 `lock_version` 作为隐藏字段加到表单中.

这个行为可以通过设置 `ActiveRecord::Base.lock_optimistically = false` 来关闭.
可以通过设置 `locking_column` 属性来覆盖 `lock_version` 字段:

```ruby
class Person < ActiveRecord::Base
  self.locking_column = :lock_person
end
```

# 例子

```console

Running via Spring preloader in process 8240
Loading development environment (Rails 5.2.1)
2.4.1 :001 > a = Article.find 1
  Article Load (0.6ms)  SELECT  "articles".* FROM "articles" WHERE "articles"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
 => #<Article id: 1, title: "头条", content: "头版头条\r\n", created_at: "2018-11-21 01:32:48", updated_at: "2018-11-21 01:32:48", lock_version: 0>
2.4.1 :002 > b = Article.find 1
  Article Load (0.3ms)  SELECT  "articles".* FROM "articles" WHERE "articles"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
 => #<Article id: 1, title: "头条", content: "头版头条\r\n", created_at: "2018-11-21 01:32:48", updated_at: "2018-11-21 01:32:48", lock_version: 0>
2.4.1 :003 > a.title = "a title"
 => "a title"
2.4.1 :004 > a.save
   (0.1ms)  begin transaction
  Article Update (0.8ms)  UPDATE "articles" SET "title" = ?, "updated_at" = ?, "lock_version" = ? WHERE "articles"."id" = ? AND "articles"."lock_version" = ?  [["title", "a title"], ["updated_at", "2018-11-22 01:35:04.392141"], ["lock_version", 1], ["id", 1], ["lock_version", 0]]
   (1.0ms)  commit transaction
 => true
2.4.1 :005 > b.title = "b title"
 => "b title"
2.4.1 :006 > b.save
   (0.1ms)  begin transaction
  Article Update (0.2ms)  UPDATE "articles" SET "title" = ?, "updated_at" = ?, "lock_version" = ? WHERE "articles"."id" = ? AND "articles"."lock_version" = ?  [["title", "b title"], ["updated_at", "2018-11-22 01:36:01.516049"], ["lock_version", 1], ["id", 1], ["lock_version", 0]]
   (0.1ms)  rollback transaction
ActiveRecord::StaleObjectError: Attempted to update a stale object: Article.
	from (irb):6
2.4.1 :007 >

```

