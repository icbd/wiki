---
layout: post
title:  Gemfile.lock是干嘛的
date:   2016-07-06
categories: ROR
---

新建Rails项目后目录里会包含 `Gemfile` 和 `Gemfile.lock` 这两个文件, Rails是通过他们来管理第三方抵赖的.

如果需要加入新的Gem,比如 `minitest-reporters`, 首先编辑 `Gemfile`, 加入 `gem 'minitest-reporters', '~> 1.1', '>= 1.1.9'`.

然后在terminal执行 `$ bundle install`, 这个Gem就安装好了.

与此同时, `Gemfile.locl` 文件也有了修改:![the change of Gemfile.lock ](/wiki/wiki/Gemfile.lock.png)

既然 `Gemfile`里已经填写了包的版本号,那为什么还需要一个 `Gemfile.lock` 文件呢?

其实`Gemfile.lock`是一份更详细的版本依赖说明,记录了当前使用的准备的版本号.

在生产环境上,我们可以用 `$ bundle install --deployment`来安装和开发环境一模一样的第三方依赖.

所以,一定记得把 `Gemfile.lock` 也加到Git中.


## 推荐阅读:

> https://richonrails.com/articles/how-does-the-gemfile-lock-file-work

