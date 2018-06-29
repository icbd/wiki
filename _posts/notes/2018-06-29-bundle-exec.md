---
layout: post
title:  what is "bundle exec" 
date:   2018-06-29
categories: Ruby
---

查看当前已经安装的 Rails 版本

```text
$ gem list | grep "^rails " 
rails (5.1.6, 5.1.3, 4.1.10)
```

系统默认的 Rails 

```text
$ which rails
/Users/focus/.rvm/gems/ruby-2.4.1/bin/rails

$ rails --version
Rails 5.1.6
```

使用 bundle exec , 指定使用 Gemfile 中规定的版本

> Gemfile
```text
gem 'rails', '4.1.10'
```

```text
$ bundle exec rails --version
Rails 4.1.10
```