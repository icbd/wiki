---
layout: post
title:  Rails验证之Error显示中文
date:   2017-06-07
categories: Rails
---

Rails scaffold 自动生成的Model 验证错误提示如下, full_messages会把字段名和错误信息一起显示.

```
<% product.errors.full_messages.each do |message| %>
  <li><%= message %></li>
<% end %>
```

在不用国际化的项目里, 手动指定中文提示,可以用下面的方式.

```
<% product.errors.messages.values.flatten.each do |message| %>
  <li><%= message %></li>
<% end %>
     
```

model 验证
```
validates :title, presence: {message: "标题不得为空"}

validates :image_url, allow_blank: true, format: {
  with: %r{\.(gif|jpg|png)\Z}i,
  message: "注意图片格式。"
}
```