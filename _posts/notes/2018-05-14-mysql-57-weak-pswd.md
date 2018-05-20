---
layout: post
title:  mysql57 弱密码  
date:   2018-05-20
categories: Mysql
---

`mysql -uroot -p`

```sql
> set global validate_password_policy=0;
> set global validate_password_length=4;
```

# 重设密码

mysql_secure_installation