---
layout: post
title:  gulp自动刷新 with nginx
date:   2017-06-26
categories: tools
---

想要的效果是编辑任意目录下的任意文件后页面自动刷新,
用 `http://react.cbd/` 这个假域名来调试.

### DEMO 目录

```
.
├── base
│   ├── babel.min.js
│   ├── react-dom.js
│   └── react.js
├── gulpfile.js
├── hello
│   └── index.html
└── index.html

```

### gulpfile.js
添加gulp的server任务, 用 `gulp server` 来启动服务.

```
var gulp = require('gulp'),
    connect = require('gulp-connect');

gulp.task('connect', function () {
    connect.server({
        host: 'react.cbd',
        port: 8080,
        root: './',
        livereload: true
    });
});

gulp.task('html', function () {
    gulp.src('./**/*.html')
        .pipe(connect.reload());
});

gulp.task('watch', function () {
    gulp.watch('./**/*.css', ['html']);
    gulp.watch('./**/*.js', ['html']);
    gulp.watch(['./**/*.html'], ['html']);
});

gulp.task('server', ['connect', 'watch']);

```

### /usr/local/etc/nginx/servers/react.cbd.conf
nginx代理, 监听80端口, 将请求转发到8080端口, 交给gulp的server处理.

```
server {
	listen 80;
    server_name react.cbd;

    #gulp 8080
    location / {
    	proxy_pass http://react.cbd:8080;
    }


    root /Users/cbd/vm/learn/JavaScript/react;
    index index.html;
}

```

### /etc/hosts
添加假域名, 令其指向本机.

```
127.0.0.1 react.cbd
```



