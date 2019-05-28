---
layout: post
title:  Rails acts_as_paranoid when UUID uniqe
date:   2019-05-28
categories: Rails
---


```ruby
class User < ApplicationRecord

  validates :uuid, :name, presence: true

  before_validation :init_uuid

  private

  def init_uuid
    return if uuid.present?

    self.uuid = SecureRandom.uuid
  end
end

```

```ruby
  create_table "users", force: :cascade do |t|
    t.string "uuid"
    t.string "name"
    t.integer "age"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["uuid"], name: "index_users_on_uuid", unique: true
  end
```

一个简单的 User 表, UUID 上有唯一索引. 使用了 `acts_as_paranoid` 之后, 添加了 `deleted_at` 的 datetime 型的字段.  

考虑这样一个情景:

```ruby
User.create name: 'u1'

=begin
      (0.1ms)  begin transaction
 User Create (0.5ms)  INSERT INTO "users" ("uuid", "name", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["uuid", "383fc521-8c04-4e7a-84e2-0915fa941498"], ["name", "u1"], ["created_at", "2019-05-28 04:02:49.512475"], ["updated_at", "2019-05-28 04:02:49.512475"]]
      (1.0ms)  commit transaction
    => #<User id: 1, uuid: "383fc521-8c04-4e7a-84e2-0915fa941498", name: "u1", age: nil, deleted_at: nil, created_at: "2019-05-28 04:02:49", updated_at: "2019-05-28 04:02:49">
=end

User.create name: 'u2'

=begin
      (0.1ms)  begin transaction
  User Create (0.8ms)  INSERT INTO "users" ("uuid", "name", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["uuid", "2c6c34e6-cf78-400f-a476-d7bd0d4d702c"], ["name", "u2"], ["created_at", "2019-05-28 04:02:51.408707"], ["updated_at", "2019-05-28 04:02:51.408707"]]
      (1.7ms)  commit transaction
    => #<User id: 2, uuid: "2c6c34e6-cf78-400f-a476-d7bd0d4d702c", name: "u2", age: nil, deleted_at: nil, created_at: "2019-05-28 04:02:51", updated_at: "2019-05-28 04:02:51"> 
=end

User.all
=begin
      User Load (0.4ms)  SELECT "users".* FROM "users" WHERE "users"."deleted_at" IS NULL LIMIT ?  [["LIMIT", 11]]
    => #<ActiveRecord::Relation [
          #<User id: 1, uuid: "383fc521-8c04-4e7a-84e2-0915fa941498", name: "u1", age: nil, deleted_at: nil, created_at: "2019-05-28 04:02:49", updated_at: "2019-05-28 04:02:49">, 
          #<User id: 2, uuid: "2c6c34e6-cf78-400f-a476-d7bd0d4d702c", name: "u2", age: nil, deleted_at: nil, created_at: "2019-05-28 04:02:51", updated_at: "2019-05-28 04:02:51">
        ]> 
=end

 User.find_by(uuid: '383fc521-8c04-4e7a-84e2-0915fa941498').destroy
=begin
      User Load (0.4ms)  SELECT "users".* FROM "users" WHERE "users"."deleted_at" IS NULL AND "users"."uuid" = ? LIMIT ?  [["uuid", "383fc521-8c04-4e7a-84e2-0915fa941498"], ["LIMIT", 1]]
      (0.1ms)  begin transaction
      User Update (0.6ms)  UPDATE "users" SET "deleted_at" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["deleted_at", "2019-05-28 04:05:15.208588"], ["updated_at", "2019-05-28 04:05:15.208612"], ["id", 1]]
      (1.5ms)  commit transaction
    => #<User id: 1, uuid: "383fc521-8c04-4e7a-84e2-0915fa941498", name: "u1", age: nil, deleted_at: "2019-05-28 04:05:15", created_at: "2019-05-28 04:02:49", updated_at: "2019-05-28 04:05:15">
=end

 User.find_by(uuid: "383fc521-8c04-4e7a-84e2-0915fa941498")
=begin
      User Load (0.2ms)  SELECT "users".* FROM "users" WHERE "users"."deleted_at" IS NULL AND "users"."uuid" = ? LIMIT ?  [["uuid", "383fc521-8c04-4e7a-84e2-0915fa941498"], ["LIMIT", 1]]
 => nil
=end

 User.find_or_create_by(uuid: "383fc521-8c04-4e7a-84e2-0915fa941498") { |user| user.name="New Name, Old User" }
=begin
      User Load (0.2ms)  SELECT "users".* FROM "users" WHERE "users"."deleted_at" IS NULL AND "users"."uuid" = ? LIMIT ?  [["uuid", "383fc521-8c04-4e7a-84e2-0915fa941498"], ["LIMIT", 1]]
      (0.1ms)  begin transaction
      User Create (0.6ms)  INSERT INTO "users" ("uuid", "name", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["uuid", "383fc521-8c04-4e7a-84e2-0915fa941498"], ["name", "New Name, Old User"], ["created_at", "2019-05-28 04:17:52.205144"], ["updated_at", "2019-05-28 04:17:52.205144"]]
      (0.1ms)  rollback transaction
      Traceback (most recent call last):
        1: from (irb):18
      ActiveRecord::RecordNotUnique (SQLite3::ConstraintException: UNIQUE constraint failed: users.uuid)
=end
```
 

## solution

数据库层次的解决方案是, 先去掉 UUID 的唯一索引, 在 UUID 和 deleted_at 上加联合索引再 unique.

```ruby
  create_table "users", force: :cascade do |t|
    t.string "uuid"
    t.string "name"
    t.integer "age"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["uuid", "deleted_at"], name: "index_users_on_uuid_and_deleted_at", unique: true
  end
```
