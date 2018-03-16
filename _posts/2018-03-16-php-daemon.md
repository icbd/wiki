---
layout: post
title:  PHP Daemon Cli
date:   2018-03-16
categories: PHP
---


```
<?php

function logging($msg, $need_change_line = true)
{
    if ($need_change_line === true) {
        $msg .= PHP_EOL;
    }
    file_put_contents("echo.log", $msg, FILE_APPEND);
}

function sleeping($second)
{
    while ($second-- > 0) {
        logging(".", false);
        sleep(1);
    }

    logging("");
}


$pid = pcntl_fork();

if ($pid < 0) {
    logging("fork 失败");
    exit();

} else if ($pid === 0) {

    // Make the current process a session leader
    posix_setsid();

    logging("son pid:" . posix_getpid());

    logging("son sleep 1s:");
    sleeping(1);
    logging("son sleep 2s:");
    sleeping(2);
    logging("son sleep 3s:");
    sleeping(3);

    logging("son exit");

} else {
    logging("father exit.");
    exit();
}
```

> http://blog.codinglabs.org/articles/write-daemon-with-php.html

