---
layout: post
title:  在 CentOS7 安装 Nginx PHP7 Mysql, Composer 部署 ThinkPHP5
date:   2018-01-18
categories: notes
---

## 安装 Centos7, 关闭 SELinux

> /etc/selinux/config

```
SELINUX=disabled
```

重启机器


## 安装 Nginx
```
yum install -y epel-release
yum install -y nginx
```

如果还显示找不到 nginx, 启用 epel 后重试:
```
yum install -y yum-utils
yum-config-manager --enable epel
yum repolist all
```

## 启动 Nginx, 设置开机自动启动
```
systemctl start nginx
systemctl enable nginx
```

## 开启防火墙支持
```
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload
```

## 安装 PHP7
```
yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum install -y yum-utils
yum-config-manager --enable remi-php71

yum --enablerepo=remi,remi-php71 install php-cli php-fpm php-common php-opcache php-pecl-apcu php-pear php-pdo php-mysqlnd php-pgsql php-pecl-mongodb php-pecl-redis php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml
```

## 配置 php-fpm

>  /etc/php-fpm.d/www.conf

```
user = www
group = www

listen.owner = www
listen.group = www

;listen = 127.0.0.1:9000
listen = /var/run/php-fpm/php-fpm.sock
```

## 开机启动 php-fpm
```
useradd -d /home/www -s /bin/bash -m www
systemctl start php-fpm.service
systemctl enable php-fpm.service
```



## 修改 Nginx 配置

> /etc/nginx/nginx.conf

```
user www;
```

## 添加 Nginx vhost 配置

```
touch /etc/nginx/conf.d/thinkphp5.vm.conf
```

```
server {
    listen   80 default_server;
    server_name  thinkphp5.vm;

    # note that these lines are originally from the "location /" block
    root   /home/www/thinkphp5/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;
    }
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

## 安装 Composer
```
php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer
composer config -g repo.packagist composer https://packagist.phpcomposer.com
```

## 安装 git
```
yum install -y git
```

## 部署代码

> git clone sth

```
cd /home/www/thinkphp5
composer install
chown www:www -R /home/www
```


## 安装 Mysql5.6

```
yum install  http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
yum install mysql-server mysql

systemctl start  mysqld.service
mysql_secure_installation
```


## phpmyadmin

```
yum install -y phpmyadmin
ln -s /usr/share/phpMyAdmin /home/www/thinkphp5/public
chown -R www:www /usr/share/phpMyAdmin
chown -R www:www /var/lib/php/session
```

## phpmyadmin auth

```
openssl passwd
echo admin:C4Qo7GTrL/1IU >> /etc/nginx/phpmyadmin_name_pswd
```

> /etc/nginx/conf.d/thinkphp5.vm.conf

```
    location /phpMyAdmin {
        auth_basic "Admin Login";
        auth_basic_user_file /etc/nginx/phpmyadmin_name_pswd;
    }
```

```
systemctl restart nginx.service
```



