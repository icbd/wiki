---
layout: post
title:  HTTP方法的幂等性与安全性
date:   2018-01-16
categories: notes
---

|---|---|---|--|
|Function|idempotent|safe|description|
|GET|YES|YES|获取实例|
|HEAD|YES|YES|获取响应头|
|OPTIONS|YES|YES|获取支持的请求方式|
|TRACE|YES|YES|追踪查看最终的请求|
|PUT|YES|NO|全量覆盖某个实例|
|POST|NO|NO|创建新实例|
|PATCH|NO|NO|修改实例的某些属性|
|DELETE|YES|NO|删除某个实例|

## 安全性 / 幂等性

安全性: 请求一次或多次, 不会改变实例的表现形式. 重点强调无副作用.
幂等性: 请求一次或多次, 响应结果相同. 重点强调副作用的一致性.


## PATCH / PUT

PUT 用于覆盖实例的全部属性, 未提及的属性默认为空值或默认值.
PATCH 用于修改实例的某个或某些属性, 未提及的属性默认不修改. PATCH 兼容性不好, 常用 POST 实现.



