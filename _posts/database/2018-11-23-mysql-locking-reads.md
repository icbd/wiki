---
layout: post
title:  Mysql Locking Reads  
date:   2018-11-23
categories: mysql
---

> [https://dev.mysql.com/doc/refman/5.7/en/innodb-locking-reads.html](https://dev.mysql.com/doc/refman/5.7/en/innodb-locking-reads.html)

# 14.7.2.4 读锁

在一个事务中, 如果先查数据, 然后对其插入或修改操作, 普通的 `SELECT` 声明并不能提供足够的保护. 其他事务还是可以更新或删除你刚刚查询到的记录.
InnoDB 提供了两种级别的读锁来提供额外的安全保障.

## 共享锁 SELECT ... LOCK IN SHARE MODE

在读到的记录上设置共享锁. 其他会话可以读这些记录, 但是在你提交事务之前, 这些记录都不能被修改.

如果其他事务对某些记录进行了修改, 但是还没有提交, 你的查询将阻塞等待, 直到其他事务完成提交. 此时你会读到最新的数据.

## 排它锁 SELECT ... FOR UPDATE

就如同使用 UPDATE 更新某些记录一样, For index records the search encounters, locks the rows and any associated index entries.
 
Consistent reads 会忽略在读取视图中记录上的任何锁.(老的记录不会被锁, 他们在内存拷贝时应用 undologs 来重建.)


这些分句在处理树形结构和图形结构的数据中很有用, 无论他们在单个表中还是跨多个表. 比如, 当你遍历图的边或树的分支的时候, 同时要求回溯来修改节点.

当事务完成提交或者事务回滚会后, 共享锁和排他锁都会释放.

> 注意

> 读锁只在"自动提交"关闭的情况下有效(通过 `START TRANSACTION` 启动事务 或者 把 `autocommit` 设置为 0 ).



除非在子查询中声明 `FOR UPDATE` , 否则含有锁定条件的外部查询也不会锁定其子查询. 下面的例子, t2 表不会上锁:

```sql

SELECT * FROM t1 WHERE c1 = (SELECT c1 FROM t2) FOR UPDATE;

```

如果要锁定t2, 需要给子查询也加上 `FOR UPDATE`:

```sql

SELECT * FROM t1 WHERE c1 = (SELECT c1 FROM t2 FOR UPDATE) FOR UPDATE;

```

# 读锁示例

假设你往 child 表 里插入一条记录, 前提条件是在 parent 表里有一条 parent 记录. 通过一系列操作, 你的代码可以保证条件的完整性.

第一步, 使用 consistent read 查询 PARENT 表, 确保 parent 记录存在. 

此时你可以安全地向 CHILD 表插入 child 记录吗? 不行, 因为此时可能有其他会话在你不知情的情况下, 在你select和insert操作之间, 把 parent 记录删除了.

为了避免这种潜在的问题, 在 select 上加 `LOCK IN SHARE MODE` :

```sql
SELECT * FROM parent WHERE NAME = 'Jones' LOCK IN SHARE MODE;
```

在 `LOCK IN SHARE MODE` 的查询之后, 你可以安全的向 CHILD 表 添加 child 字段了, 并且提交事务.

这样一来, 其他任何事务要想获得PARENT表中相关记录的排它锁, 就要等待你的事务的完成. 至此, 所有表中的数据达到一致的状态.


另外一个例子.

假设有表 CHILD, 其中有整型类型的计数字段 CHILD_CODES ,作为唯一标识符标记每个 child .

这种情况下, 既不要用 consistent read 也不要用 共享锁读, 因为数据库的两个用户会看到相同的 CHILD_CODES , 如果两个事务设置多个 CHILD_CODES 字段为相同的值, 就会产生键值重复的问题.

此时, ` LOCK IN SHARE MODE ` 并不是好的方案, 因为如果有两个用户同时用共享锁读来读取 CHILD_CODES , 当他们要更新 CHILD_CODES , 至少有一个用户将以死锁结束. (译者注释: 一个用户抛死锁异常, 一个用户正常结束)

要实现对 CHILD_CODES 的先查询再修改, 要使用排它锁读, 再修改. 例如: 

(译者注: 感觉这个例子不太恰当~)

```sql
SELECT counter_field FROM child_codes FOR UPDATE;
UPDATE child_codes SET counter_field = counter_field + 1;
```

`FOR UPDATE` 总是读到最新的有效数据, 并且对这些数据加排它锁. 它与 UPDATE 更新字段时设置的锁相同.

之前的例子只是用来说明 `SELECT ... FOR UPDATE` 如何工作. 在 MYSQL 中, 产生唯一标识符的任务可以在一句SQL内完成.

```sql
UPDATE child_codes SET counter_field = LAST_INSERT_ID(counter_field + 1);
SELECT LAST_INSERT_ID();
```

第二句的select只会返回之前 `counter_field + 1` 的值(限于当前连接), 不会重新读表.(译者注: `LAST_INSERT_ID()` 的功能只是对当前session的信息暂存, 不用误用)



> ---分割线---


# 演示1 

线程1使用事务, 更新一条记录. 该update操作会给该记录上行级锁.
此时尚未提交:

```
mysql> begin;
Query OK, 0 rows affected (0.01 sec)

mysql> UPDATE gamble_checkin_activities SET title = "new title" where id = 1;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

如果线程2直接读, 得到老数据:

```
mysql> SELECT title FROM gamble_checkin_activities where id = 1 ;
+-----------+
| title     |
+-----------+
| old title |
+-----------+
1 row in set (0.00 sec)
```

如果线程2使用排他锁读, 因为已经有update锁住了该记录, 所以for update排它锁会阻塞:

```

mysql> SELECT title FROM gamble_checkin_activities where id = 1 for update;
^C^C -- query aborted
ERROR 1317 (70100): Query execution was interrupted

```

如果线程2使用共享锁, 还是因为update锁的原因, lock in share mode 也会被阻塞:

```
mysql> SELECT title FROM gamble_checkin_activities where id = 1 lock in share mode;
^C^C -- query aborted
ERROR 1317 (70100): Query execution was interrupted
```

线程1commit之后, 三种读都可以读到, 而且读到了更新后的数据.

# 演示2

线程1包在事务中, 使用共享锁读数据, 事务未提交:

```
mysql> begin;
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT title FROM gamble_checkin_activities where id = 1 lock in share mode;
+-----------+
| title     |
+-----------+
| new title |
+-----------+
1 row in set (0.00 sec)
```

线程2 直接读和共享锁读都可以读到. 排它锁读被阻塞. update 操作被阻塞.

# 演示3

线程1包在事务中, 使用排他锁读数据, 事务未提交:

```
mysql> begin;
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT title FROM gamble_checkin_activities where id = 1 for update;
+-----------+
| title     |
+-----------+
| new title |
+-----------+
1 row in set (0.00 sec)
```

线程2直接读可以读到. 共享锁读/排它锁读 被阻塞. update 操作被阻塞.

# 小结:

`lock in share mode` 为共享锁, 加锁的记录别人可读不可写;

`for update` 为排他锁, 加锁的记录别人不可读也不可写;

两种锁对当前查询来说都需要先获得锁, 意思是说如果别人正在持有该记录的锁, 自己当前对该记录的查询将阻塞. 