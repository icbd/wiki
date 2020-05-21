---
layout: post
title:  WebServlet 优先级    
date:   2020-05-22
categories: Servlet
---

默认的 `web.xml` 中有这样一段配置, 用来匹配 URL 和 Servlet 的映射关系:
```
<servlet-mapping>
    <servlet-name>default</servlet-name>
    <url-pattern>/</url-pattern>
</servlet-mapping>

<!-- The mappings for the JSP servlet -->
<servlet-mapping>
    <servlet-name>jsp</servlet-name>
    <url-pattern>*.jsp</url-pattern>
    <url-pattern>*.jspx</url-pattern>
</servlet-mapping>
```

一个 Servlet 可以由多个路由对应.

在 Servlet 3之后, 更习惯用 `@WebServlet` 注解来代替 xml 中的 `servlet-mapping` 标签.

某些路由是从上到下顺序匹配, 但是 Servlet 散落在各个文件中. 

`@WebServlet` 路由的匹配关系如下:
1. 精确匹配
2. 最长路径匹配
3. `/*`
4. 扩展名

#### 注意

* 慎用 `/*`, 会造成循环 dispatch 的问题, 匹配所有应该用 `/`;
