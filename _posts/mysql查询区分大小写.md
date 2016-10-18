---
layout: post
title:  mysql 查询区分大小写
date:   2016-10-18
categories: DB
---

mysql where 默认不区分字段的大小写.
除了修改数据库配置之外,可以在明确大小敏感的条件前加'binary':

```
SELECT
	*
FROM
	`learn`
WHERE
	BINARY NAME = 'bob'
AND BINARY city = 'beijing';
```
