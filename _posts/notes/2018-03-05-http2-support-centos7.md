---
layout: post
title:  Nginx HTTP2 服务器推送
date:   2018-03-05
categories: nginx
---

## 安装 Nginx 主干版本

[https://nginx.org/en/linux_packages.html#stable](https://nginx.org/en/linux_packages.html#stable)

Nginx 1.13.9 开始支持 HTTP2, 在 centos7 上使用 Nginx 官方源进行升级:


> /etc/yum.repos.d/nginx.repo

```
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/$basearch/
gpgcheck=0
enabled=1
```

```
yum install nginx
```

## 配置开发环境HTTPS证书

新建私钥

```
openssl genrsa -out priv_key 1024/2038
```

生成证书(公钥)

```
openssl req -new -x509 -key priv_key -out server.pem
```

```
server {
    listen 443 ;
    server_name main.vm;

    ssl on;
    ssl_certificate /etc/nginx/https_cert/server_cert;
    ssl_certificate_key /etc/nginx/https_cert/priv_key;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
```


## 添加 HTTP2 配置

```
server {
    listen 443 http2;
    server_name main.vm;

    ssl on;
    ssl_certificate /etc/nginx/https_cert/server_cert;
    ssl_certificate_key /etc/nginx/https_cert/priv_key;

    location / {
        root /usr/share/nginx/html;
        index index.html;

        http2_push /logo.png;
    }
}
```

重启nginx后刷新页面(disable cache), logo.png 的 Initiator 变为 `Push/(index)`


## PHP 与 HTTP2

在普通请求中添加额外的logo.png推送, 需要做的是在响应的时候写 `link` 头部信息:

> Response Headers

```
content-type:text/html; charset=utf-8
date:Mon, 05 Mar 2018 07:21:01 GMT
link:</logo.png>; rel=preload; as=image
server:nginx/1.13.9
status:200
x-powered-by:PHP/7.1.13
```

PHP示例:

```
header("Link: </logo.png>; rel=preload; as=image", false);
```

第二个参数 `false` 说明不覆盖, 只追加.


对应模板文件来验证:
(启用cache)

```
<div id="pic">pic</div>
<script>
setTimeout(function(){
        alert('load pic');
        document.getElementById('pic').innerHTML='<img src="/logo.png">';
},3000);
</script>
```

刷新页面, 第一个GET请求访问 `index.html`, 同时Server推送 `logo.png` 文件.
3秒后, JS 创建 `<img>` ,此时浏览器已经缓存有 `logo.png` 文件, 直接加载.

(3秒后Server仍然收到了GET请求.)


> 参考

[https://blog.cloudflare.com/using-http-2-server-push-with-php/](https://blog.cloudflare.com/using-http-2-server-push-with-php/)

[http://lzw.me/a/http2-nginx.html](http://lzw.me/a/http2-nginx.html)




