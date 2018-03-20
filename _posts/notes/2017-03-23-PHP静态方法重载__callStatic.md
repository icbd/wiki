---
layout: post
title:  PHP静态方法重载 __callStatic
date:   2017-03-23
categories: notes
---

# 方法重载

当调用一个不存在的方法时, 会触发方法重载. 不同于Java的方法重载, PHP的overloading更像是参数的默认值 和 自动加载.

** 重载方法都必须被声明为 public, 且参数不能通过引用传递. **

这里只说`__callStatic`.


## 方法原型

```
public static mixed __callStatic ( string $name , array $arguments )
```

第一个参数是方法名; 第二个是方法参数, 注意它是个array.


## 实例展示

源码来自laravel5.4的Facades.

功能:

```
App::environment();     //获取当前环境 => String
App::environment('local', 'staging');       //判断当前环境是否在符合要求 => Boolean
```


> /vendor/laravel/framework/src/Illuminate/Support/Facades/Facade.php

```
/**
     * Handle dynamic, static calls to the object.
     *
     * @param  string  $method
     * @param  array   $args
     * @return mixed
     *
     * @throws \RuntimeException
     */
    public static function __callStatic($method, $args)
    {
        $instance = static::getFacadeRoot();

        if (! $instance) {
            throw new RuntimeException('A facade root has not been set.');
        }

        return $instance->$method(...$args);
    }
```


> /vendor/laravel/framework/src/Illuminate/Foundation/Application.php

```
    /**
     * Get or check the current application environment.
     *
     * @return string|bool
     */
    public function environment()
    {
        if (func_num_args() > 0) {
            $patterns = is_array(func_get_arg(0)) ? func_get_arg(0) : func_get_args();

            foreach ($patterns as $pattern) {
                if (Str::is($pattern, $this['env'])) {
                    return true;
                }
            }

            return false;
        }

        return $this['env'];
    }
```
