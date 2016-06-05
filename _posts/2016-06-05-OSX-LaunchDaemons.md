---
layout: post
title:  OSX 开机自动启动Redis/Nginx/php-fpm
date:   2016-06-05
categories: 配置
---

## 开机启动Nginx php-fpm

> 不需要参数的命令行

```
$ cat /Library/LaunchDaemons/org.phpfpm.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>org.phpfpm</string>
	<key>RunAtLoad</key>
	<true/>
	<key>Program</key>
	<string>/usr/local/php7/bin/php-fpm</string>
</dict>
</plist>

```

```
$ cat /Library/LaunchDaemons/org.nginx.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>org.nginx</string>
	<key>RunAtLoad</key>
	<true/>
	<key>Program</key>
	<string>/usr/local/bin/nginx</string>
</dict>
</plist>

```

## 开机自启动 Redis

> 需要参数的命令行
> sudo /Users/cbd/devel/redis-3.2.0/src/redis-server /Users/cbd/devel/redis-3.2.0/redis.conf

```
$ cat /Library/LaunchDaemons/org.redis.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>org.redis</string>
	<key>RunAtLoad</key>
	<true/>
	<key>ProgramArguments</key>
        <array>
            <string>/Users/cbd/devel/redis-3.2.0/src/redis-server</string>
            <string>/Users/cbd/devel/redis-3.2.0/redis.conf</string>
        </array>
</dict>
</plist>
```

## 加载

```
$ sudo launchctl load /Library/LaunchDaemons/org.phpfpm.plist
$ sudo launchctl load /Library/LaunchDaemons/org.redis.plist
$ sudo launchctl load /Library/LaunchDaemons/org.nginx.plist
```

## 查看
```
$ ps -ef | grep -E 'php|nginx|redis'
```
