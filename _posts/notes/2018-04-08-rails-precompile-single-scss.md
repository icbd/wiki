---
layout: post
title:  Rails单独加载一个SCSS样式
date:   2018-04-08
categories: Rails
---

## 需求背景

想做一个有设计感的 welcome 页面, 整体布局和样式跟其他页面有较大差异, 所以想把它单独抽离出来.

## layout

```
  def welcome
    render layout: false
  end
```

## SCSS

1. 在 `application.css` 中使用 `stub`, 以除去对 welcome.scss 的引入.

```
*= stub "welcome"
```

2. 添加 Asset Pipeline 预编译配置:

```
# DIY global config
Rails.application.configure do
  config.assets.precompile += %w( welcome.css )
end
```

3. 在 welcome 页面中引入 welcome 样式

```
<%= stylesheet_link_tag 'welcome' %>
```

