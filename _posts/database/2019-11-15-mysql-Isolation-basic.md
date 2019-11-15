---
layout: post
title:  MySQL Isolation Levels
date:   2019-11-15
categories: MySQL
---

# MySQL Isolation Levels

事务的四大特性 ACID(Atomicity, Consistency, Isolation, Durability), 这里只看 `I`: Isolation.

## MySQL InnoDB Isolation Levels

InnoDB 的隔离性的默认值为 `REPEATABLE-READ`, 也可以通过SQL修改当前 `SESSION` 的或者 `GLOBAL` 的隔离性.

隔离级别主要针对读取数据的一方, 限定自身可以读到什么阶段的数据.

关于 MySQL 隔离级别的设置:

Syntax	| Affected Characteristic Scope
---|---
`SET GLOBAL TRANSACTION transaction_characteristic`	| Global
`SET SESSION TRANSACTION transaction_characteristic`	| Session
`SET TRANSACTION transaction_characteristic`	| Next transaction only

Syntax |	Affected Characteristic Scope
---|---
`SET GLOBAL var_name = value` |	Global
`SET @@GLOBAL.var_name = value` |	Global
`SET PERSIST var_name = value` |	Global
`SET @@PERSIST.var_name = value` |	Global
`SET PERSIST_ONLY var_name = value` |	No runtime effect
`SET @@PERSIST_ONLY.var_name = value` |	No runtime effect
`SET SESSION var_name = value` |	Session
`SET @@SESSION.var_name = value` |	Session
`SET var_name = value` |	Session
`SET @@var_name = value` |	Next transaction only

值得注意的是, 当我们使用 `SET TRANSACTION transaction_characteristic` 或者 `SET @@var_name = value`, 只会影响到下一个事务, 当然这也正是我们想要的(大部分情况).

以下都在普通 `SELECT` 下进行.

### READ UNCOMMITTED

该级别下, 可以读到未经提交的事务.

如果对面的事务中途 Rollback 了, 刚刚读到的数据也就是无效的数据. 此所谓 `脏读`.

### READ COMMITTED

该级别下, 只可读到已经提交的事务(读不到还未提交的事务).

如果本事务中有两个查询, 在两次查询之间有其他事务修改了相关的数据. 在该级别的事务中, 两次条件相同的读操作, 得到的数据不一致. 此所谓 `不可重复读`.

### REPEATABLE READ

该级别下, 只可读到已经提交的事务, 并且能保证同一个事务内可重复读.

如果本事务中有两个查询, 在两次查询之间有其他事务修改了相关的数据. 在该级别的事务中, 两次条件相同的读操作, 得到的数据相同. 即本事务的第二次查询, 读不到其他事务刚刚已经提交的相关数据.

如果本事务要更新一批数据, 其他事务插入了一些相关的新数据, 本事务将更新不到新插入的数据. 此所谓 `幻读` . 

### SERIALIZABLE

该级别下, 只能读到已经提交的事务, 并且能保证同一个事务内可重复读, 并且会阻塞其他事务向查询的区间插入新数据(若插入的数据不在区间内, 则可以正常插入). 

### Sum-up

Isolation Level | Dirty Read | NonRepeatable Read | Phantom Read
---|---|---|---
READ UNCOMMITTED | √ | √ | √ 
READ COMMITTED | × | √ | √ 
REPEATABLE READ | × | × | √ 
SERIALIZABLE | × | × | × 

# Read More:

[https://dev.mysql.com/doc/refman/8.0/en/set-transaction.html](https://dev.mysql.com/doc/refman/8.0/en/set-transaction.html)

[https://dev.mysql.com/doc/refman/8.0/en/innodb-transaction-isolation-levels.html](https://dev.mysql.com/doc/refman/8.0/en/innodb-transaction-isolation-levels.html)

[https://dev.mysql.com/doc/refman/8.0/en/innodb-locking.html](https://dev.mysql.com/doc/refman/8.0/en/innodb-locking.html)
