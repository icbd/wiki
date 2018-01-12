---
layout: post
title:  Nginx $arg_ 内建变量
date:   2018-01-12
categories: notes
---

# $arg_sth

内建变量.
$arg_sth 的值为当前请求中 `sth` 所对应的查询值, 该值为未解码的原始值.(解码可使用 set_unescape_uri)
`sth`不存在或者值为空时, $arg_sth 都是空字符串. (使用 ngx_lua 明确区分)
`sth` 大小写不敏感.
运行时动态解析, 无缓存.
存在多个 `sth` 时, 取第一个所对应的值.
父子变量隔离.

```
        location /test {
            add_header Content-Type 'text/html;charset=utf-8';
            echo "key:$arg_key.";
        }
```

```
cbd@Baodong-MBP:~$ curl http://192.168.56.101/test?key=123
key:123.
cbd@Baodong-MBP:~$ curl 'http://192.168.56.101/test?key=你 好'
key:你 好.
cbd@Baodong-MBP:~$ curl 'http://192.168.56.101/test?key=你%20好'
key:你%20好.
cbd@Baodong-MBP:~$ curl http://192.168.56.101/test
key:.
cbd@Baodong-MBP:~$ curl http://192.168.56.101/test?
key:.
cbd@Baodong-MBP:~$ curl http://192.168.56.101/test?key
key:.
cbd@Baodong-MBP:~$ curl http://192.168.56.101/test?key=
key:.
cbd@Baodong-MBP:~$ curl http://192.168.56.101/test?KeY=123
key:123.
cbd@Baodong-MBP:~$ curl 'http://192.168.56.101/test?key=123&key=456'
key:123.
```


```
        location /test {
            add_header Content-Type 'text/html;charset=utf-8';
            echo "main key 1:$arg_key.";
            echo_location /sub "key=subkey";
            echo "main key 2:$arg_key.";
        }

        location /sub {
            echo "sub: $arg_key.";
        }
```

```
cbd@Baodong-MBP:~$ curl http://192.168.56.101/test?key=123
main key 1:123.
sub: subkey.
main key 2:123.
```

# 备注

Nginx 版本:

```
nginx version: nginx/1.12.2
```

编译参数:

```
./configure \
 --with-http_ssl_module \
 --with-http_v2_module \
 --with-http_mp4_module \
 --with-http_flv_module \
 --add-module=/root/source_code/echo-nginx-module-0.61 \
 --add-module=/root/source_code/lua-nginx-module-0.10.12rc1 
```
