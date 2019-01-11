---
layout: post
title:  Rails 5.1 打印缓存 log
date:   2019-01-11
categories: Rails
---

```bash
$ rails --version
Rails 5.2.2
```

该版本默认已经不输出缓存log了.
 
在开发时调试俄罗斯套娃缓存还是希望看到 `read fragment` 的过程的, 可以通过以下配置开启:

> config/environments/development.rb

```ruby
config.action_controller.enable_fragment_cache_logging = true
```

缓存开关:

```bash
bundle exec rails dev:cache
```

开启缓存后效果如下:

```text
Started GET "/" for 127.0.0.1 at 2019-01-11 11:03:08 +0800
   (0.1ms)  SELECT "schema_migrations"."version" FROM "schema_migrations" ORDER BY "schema_migrations"."version" ASC
  ↳ /Users/baodongcao/.rvm/gems/ruby-2.5.3/gems/activerecord-5.2.2/lib/active_record/log_subscriber.rb:98
Processing by StoreController#index as HTML
  Rendering store/index.html.erb within layouts/application
   (0.1ms)  SELECT COUNT(*) AS "size", MAX("products"."updated_at") AS timestamp FROM "products"
  ↳ app/views/store/index.html.erb:7
  Product Load (0.2ms)  SELECT "products".* FROM "products" ORDER BY "products"."title" ASC
  ↳ app/views/store/index.html.erb:7
Read fragment views/store/index:13d2ad5e36b5af3b652c09ecd007dc6b/products/query-472c5e944ebe4d9a8d77c3b8cccbda69-3-20190111024515016842 (12.8ms)
Read fragment views/store/index:13d2ad5e36b5af3b652c09ecd007dc6b/products/5-20190111024515010144 (0.1ms)
Write fragment views/store/index:13d2ad5e36b5af3b652c09ecd007dc6b/products/5-20190111024515010144 (0.2ms)
Read fragment views/store/index:13d2ad5e36b5af3b652c09ecd007dc6b/products/7-20190111024515016842 (0.1ms)
Write fragment views/store/index:13d2ad5e36b5af3b652c09ecd007dc6b/products/7-20190111024515016842 (0.1ms)
Read fragment views/store/index:13d2ad5e36b5af3b652c09ecd007dc6b/products/6-20190111024515013454 (0.1ms)
Write fragment views/store/index:13d2ad5e36b5af3b652c09ecd007dc6b/products/6-20190111024515013454 (0.2ms)
Write fragment views/store/index:13d2ad5e36b5af3b652c09ecd007dc6b/products/query-472c5e944ebe4d9a8d77c3b8cccbda69-3-20190111024515016842 (0.3ms)
  Rendered store/index.html.erb within layouts/application (199.7ms)
Completed 200 OK in 235ms (Views: 227.2ms | ActiveRecord: 0.8ms)


Started GET "/" for 127.0.0.1 at 2019-01-11 11:03:20 +0800
Processing by StoreController#index as HTML
  Rendering store/index.html.erb within layouts/application
   (0.2ms)  SELECT COUNT(*) AS "size", MAX("products"."updated_at") AS timestamp FROM "products"
  ↳ app/views/store/index.html.erb:7
  Product Load (0.2ms)  SELECT "products".* FROM "products" ORDER BY "products"."title" ASC
  ↳ app/views/store/index.html.erb:7
Read fragment views/store/index:13d2ad5e36b5af3b652c09ecd007dc6b/products/query-472c5e944ebe4d9a8d77c3b8cccbda69-3-20190111024515016842 (2.0ms)
  Rendered store/index.html.erb within layouts/application (5.2ms)
Completed 200 OK in 24ms (Views: 21.6ms | ActiveRecord: 0.3ms)

```