---
layout: post
title:  rails has_secure_password
date:   2018-04-09
categories: Rails
---

在模型中使用 `has_secure_password` 可以很方便的用 `Bcrypt` 算法处理用户密码.

此时会引入这样几个方法:

```
authenticate(unencrypted_password)
password=(unencrypted_password)
password_confirmation=(unencrypted_password)
```

当 `password_confirmation` 值为 nil, 用 `password=` 直接设置密码, 存储在 `password_digest` 字段.

当 `password_confirmation` 值不为 nil, 用 `password=` 设置密码前会校验两个值一致.

使用 `authentication` 校验密码, 简便写法:

```
User.find_by(name: 'david').try(:authenticate, 'mUc3m00RsqyRe') # => user
```

## 注意

* 密码明文不能为空
* 密码明文长度小于等于72

