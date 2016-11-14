---
layout: post
title:  mysql ROW_NUMBER()
date:   2016-11-14
categories: mysql
---

mysql中不支持 `ROW_NUMBER()` 函数, 可以用变量累加实现.
@floorNum 和 limit 的偏移量应该保持一致, 这样分页时也可以保证全局序号一致.

```
SET @floorNum = 2;

SELECT
	(@floorNum := @floorNum + 1) AS floorNum ,
	dis.*, u.face ,
	u.nick
FROM
	discuss AS dis ,
	users AS u
WHERE
	tieno = 2
AND tieid = 1660
AND dis.user_id = u.id
ORDER BY
	create_time ASC ,
	id ASC
LIMIT 2 ,
 3;
```