---
layout: post
title:  UNIX 时间戳总结
date:   2017-12-12
categories: notes
---

## 维基中的定义:

> UNIX时间，或称POSIX时间是UNIX或类UNIX系统使用的时间表示方式：从协调世界时1970年1月1日0时0分0秒起至现在的总秒数，不考虑闰秒。
> 在多数Unix系统上Unix时间可以通过 `date +%s` 指令来检查。

特别注意: 标准的 UNIX时间 是默认 UTC(Coordinated Universal Time) 时区的.

在php中, time() 方法返回UTC时区下, 1970-01-01 00:00:00 至今的秒数, 跟php.ini和服务器的时区设置都无关.

在mysql中, timestamp 类型保存确实是 UNIX时间, 但select的时候会结合数据库配置的当地时间 以 `2017-12-07 18:40:28` 这样的格式显示.
datetime 类型只保存了时间的字面值, 时区无关, 需要开发者自己维护.


## 查看mysql时区设置:

```
mysql> select @@global.time_zone, @@session.time_zone;
+--------------------+---------------------+
| @@global.time_zone | @@session.time_zone |
+--------------------+---------------------+
| SYSTEM             | SYSTEM              |
+--------------------+---------------------+
1 row in set (0.00 sec)

```

说明配置跟随系统.

## 查看系统时区设置:

```
# date
Tue Dec 12 17:32:31 CST 2017

```

说明是CST时区, China Standard Time, 即 `Asia/Shanghai`

## 修改系统时区为 UTC, 重启mysql使其生效

```
# timedatectl set-timezone UTC
# systemctl restart mysqld
```

## insert 测试数据:
name 表中 ct 为 timestamp , 为空时自动填充当前时间戳, ct_date 为 datetime.

```
mysql> insert into name (name, gender) values ('XiaoMing', 'boy');
mysql> update name set ct_date = '2017-12-12 09:41:55' where id = 2;
mysql> insert into name (name, gender, ct, ct_date) values ('XiaoMing', 'boy', '2017-12-12 11:11:11', '2017-12-12 11:11:11');

mysql> select * from name where 1;
+----+----------+--------+---------------------+---------------------+
| id | name     | gender | ct                  | ct_date             |
+----+----------+--------+---------------------+---------------------+
|  1 | Focus    | secret | 2017-12-07 10:04:59 | 2017-12-07 18:04:59 |
|  2 | XiaoMing | boy    | 2017-12-12 09:41:55 | 2017-12-12 09:41:55 |
|  3 | XiaoMing | boy    | 2017-12-12 11:11:11 | 2017-12-12 11:11:11 |
+----+----------+--------+---------------------+---------------------+
3 rows in set (0.00 sec)

```

## 修改系统时区为 CST

```
# timedatectl set-timezone Asia/Shanghai
# systemctl restart mysqld

mysql> select * from name;
+----+----------+--------+---------------------+---------------------+
| id | name     | gender | ct                  | ct_date             |
+----+----------+--------+---------------------+---------------------+
|  1 | Focus    | secret | 2017-12-07 18:04:59 | 2017-12-07 18:04:59 |
|  2 | XiaoMing | boy    | 2017-12-12 17:41:55 | 2017-12-12 09:41:55 |
|  3 | XiaoMing | boy    | 2017-12-12 19:11:11 | 2017-12-12 11:11:11 |
+----+----------+--------+---------------------+---------------------+
3 rows in set (0.00 sec)
```

## 结论很明显:

datetime 格式的值跟时区无关, 字面值不变.
timestamp 格式的值所表示的 UNIX时间戳 的值不变, 但会根据设置的时区显示当地的时间(时区相关).


## mysql 中的时间戳转换函数:
unix_timestamp, 将日期(在当地时区下)转为时间戳.
from_unixtime, 将时间戳转为日期(显示为当地时区).

```
mysql> select *, unix_timestamp(ct), unix_timestamp(ct_date), from_unixtime(0) from name where id = 1;
+----+-------+--------+---------------------+---------------------+--------------------+-------------------------+---------------------+
| id | name  | gender | ct                  | ct_date             | unix_timestamp(ct) | unix_timestamp(ct_date) | from_unixtime(0)    |
+----+-------+--------+---------------------+---------------------+--------------------+-------------------------+---------------------+
|  1 | Focus | secret | 2017-12-07 18:04:59 | 2017-12-07 18:04:59 |         1512641099 |              1512641099 | 1970-01-01 08:00:00 |
+----+-------+--------+---------------------+---------------------+--------------------+-------------------------+---------------------+
1 row in set (0.00 sec)
```



