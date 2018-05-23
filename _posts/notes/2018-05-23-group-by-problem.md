---
layout: post
title:  一个GroupBy的错误用法  
date:   2018-05-23
categories: SQL
---

需求: 统计 `crm_goods_order_items` 表里的商品, 输出结果时要求带上商品的分类.

查找路径是由 `crm_goods_order_items` 的 `goods_id` 找到 `goods` 表中的对应商品, 该商品有 `category_id`.

由 `category_id` 去 `categories` 表, 由 `id` 找到对应的 `name`.

## 第一版SQL:

```sql
SELECT
  goods_id,
  sum( quantity ) AS quantity,
  sum( sum_price ) AS sum_price,
  sum( profit ) AS profit,
  goods.category_id,
  (
SELECT
  `categories`.NAME 
FROM
  `categories` 
WHERE
  `categories`.id = goods.category_id 
  ) AS category_name 
FROM
  `crm_goods_order_items`
  INNER JOIN `goods` ON `goods`.`id` = `crm_goods_order_items`.`goods_id`,
  `categories` 
WHERE
  ( `crm_goods_order_items`.`the_date` BETWEEN '2018-05-21' AND '2018-05-23' ) 
GROUP BY
  `crm_goods_order_items`.`goods_id` 
ORDER BY
  profit DESC;
```

很不明显的是, 这个SQL有逻辑上的错误, 结果是错的, 每个统计结果是正确值的10倍(categories表有10条记录).

## 正确的SQL:

```sql
SELECT
	table1.*,
  categories.NAME AS category_name 
FROM
	(
SELECT
	goods_id,
	sum( quantity ) AS quantity,
	sum( sum_price ) AS sum_price,
	sum( profit ) AS profit,
	goods.category_id 
FROM
	`crm_goods_order_items`
	INNER JOIN `goods` ON `goods`.`id` = `crm_goods_order_items`.`goods_id` 
WHERE
	( `crm_goods_order_items`.`the_date` BETWEEN '2018-05-21' AND '2018-05-23' ) 
GROUP BY
	`crm_goods_order_items`.`goods_id` 
	) table1
	JOIN categories ON table1.category_id = categories.id 
ORDER BY
	table1.profit DESC;
```

把 `group by` 的逻辑包在子查询里就不会有这种错误, 另外, 应该把 `order by` 移到外面来.


Stack Overflow 上有类似的例子可以试一下: [https://stackoverflow.com/questions/3320863/get-sum-in-group-by-with-join-using-mysql](https://stackoverflow.com/questions/3320863/get-sum-in-group-by-with-join-using-mysql)
