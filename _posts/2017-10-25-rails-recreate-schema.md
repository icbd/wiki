---
layout: post
title:  重新生成schema文件
date:   2017-10-25
categories: Rails
---

开发环境下, 想在原 migrate 上做修改时, 可以使用 `rails db:migrate:reset` 命令, 重新生成 schema 并重置数据库.
如果提示 `DETAIL:  There are x other sessions using the database.` ,
断开 postgres 连接或直接重启 postgres.


 db:命令|    用途
---|---
db:schema:dump|  更新schema文件
db:rollback|    回滚一个迁移
db:rollback STEP=3|    回滚三个迁移
db:migrate:redo|    回滚一个迁移并重试它
db:migrate:redo STEP=3|    回滚三个迁移并重试它们
db:setup|   创建数据库,添加种子数据
db:reset|   根据schema.rb或structure.sql重置数据库
db:migrate:up VERSION=20171025120000|   运行指定的迁移 (如果执行过就跳过执行)
db:migrate RAILS_ENV=test|  运行指定环境下的迁移