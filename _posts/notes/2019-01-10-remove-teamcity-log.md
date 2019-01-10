---
layout: post
title:  RubyMine remove TeamCity Log
date:   2019-01-10
categories: RubyMine
---

安装了新版 Rubymine之后, 运行测试的时候会附加打印很多 `teamcity` 的 log.

`TeamCity` 是 IDEA 出品的CI工具, 但是很多时候我们并不需要, 禁用这些不必要的log需要清空(或重命名)以下目录:

`/Applications/RubyMine.app/Contents/rb/testing`
