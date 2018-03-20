---
layout: post
title:  CLion Cmake Multi target
date:   2017-01-15
categories: TOOLS
---

Xcode8开始禁用第三方插件,快捷键各种不舒服,还是切换到jetbrains家的Clion了.

A cross-platform IDE for C and C++ [https://www.jetbrains.com/clion/](https://www.jetbrains.com/clion/).

`CLion 2016.3.2` 现在只支持[Cmake](https://cmake.org/).
Cmake用来生成makefile,也可以导出xcode项目或VS项目,优势是跨平台和句法简洁.

下面小结一下配置过程:

## 项目目录树

![clion1.png](/wiki/wiki/clion1.png)

## 根CmakeLists.txt

每个目录都有一个CmakeLists.txt.
这是根目录下的CmakeLists.txt, `#`为注释.
Cmake命令不区分大小写,命名的关键词区分.

```
# 指定使用cmake版本最低是3.6
CMAKE_MINIMUM_REQUIRED(VERSION 3.6)

# 项目名
PROJECT(data_structure)

# 引入子目录
ADD_SUBDIRECTORY(data_structure)
ADD_SUBDIRECTORY(LNode_test)
ADD_SUBDIRECTORY(LNode)

```

## data_structure/CmakeLists.txt

项目的主入口`main.c`放在这个目录下,
现在还只有一个HelloWorld,只需要生成一个target就能让他跑起来.
`SET` 用来设置一个命名,即`data_structure_SRC`包含了`main.c`这个文件.
`ADD_EXECUTABLE`生成可执行的target.

```
SET(data_structure_SRC
        main.c
        )
ADD_EXECUTABLE(data_structure ${data_structure_SRC})
```

设置好这一步就可以点IDE右上角`Run/Debug Configurations`.
如果还跑步起来就手动清理`cmake-build-debug`目录再 `Reload Cmake Project`.

![clion2.png](/wiki/wiki/clion2.png)

![clion3.png](/wiki/wiki/clion3.png)


## LNode/CmakeLists.txt

LNode是一个简单的单向链表库.
`ADD_LIBRARY`添加库,库名为`LNode`,库文件是`LNode_SRC`中定义的.

```
SET(LNode_SRC
        LNode.c
        )
ADD_LIBRARY(LNode ${LNode_SRC})
```

## LNode_test/CmakeLists.txt

`LNode_test/main.c` 用来测试LNode,把它设为另一个target,
区别于项目的主入口`data_structure/target`的main.

`${PROJECT_SOURCE_DIR}`是个Cmake自动生成的全局变量,指向项目根目录.

```
# 引入库
INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/LNode)

SET(LNode_test_SRC
        main.c
        )

# 生成可执行的target
ADD_EXECUTABLE(LNode_test ${LNode_test_SRC})
# 链接库
TARGET_LINK_LIBRARIES(LNode_test LNode)
```

# 扩展阅读

[cmake 学习笔记](http://blog.csdn.net/dbzhang800/article/details/6314073)

[在 linux 下使用 CMake 构建应用程序](http://www.ibm.com/developerworks/cn/linux/l-cn-cmake/)

[mastering-cmake.pdf](https://raw.githubusercontent.com/Akagi201/learning-cmake/master/mastering-cmake.pdf)