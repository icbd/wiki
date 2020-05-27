---
layout: post
title:  JVM 内存结构概述
date:   2020-05-26
categories: JVM
---

JVM 的内存模型粗略可以分成堆和栈:
* 堆区分为 堆(Heap)和方法区(Method Area);
* 栈区分为 程序计数器(Program Counter Register), 虚拟机栈(VM Stack), 本地方法栈(Native Method Stack).

堆区的内存为所有线程共享, 栈区的内存为各个线程独占.


* 程序计数器 PC Register:

	java 的线程对应 OS 中的线程, java 多线程通过线程轮流切换, 依次分配 CPU 时间来实现.
	在某个确定的时刻, 一个 CPU 内核只会执行一个线程.
	程序计数器记录了 JVM 在执行本线程时, 字节码指令的位置. 
	为线程切换后, 让 JVM 知道指令要在哪继续执行, 每个线程都持有各自的程序计数器.

* 虚拟机栈 VM Stack:
	
	每个线程维护自己的虚拟机栈. 
	每执行一个方法, JVM 就同步创建一个栈帧(Stack Frame), 用来存放该方法的局部变量表, 操作数栈, 动态连接, 方法出口等.
	执行方法, 栈帧入栈; 方法执行完成, 栈帧出栈.

* 本地方法栈 Native Method Stack:
	
	用于执行本地方法的 Stack.

* 堆 Heap:
	
	所有对象实例和数组都在堆上分配, 垃圾收集器管理他们的回收工作.
	堆可以分配在连续的物理内存上, 也可以分配在不连续的内存空间上, 但堆在逻辑上是连续的.
	Hotspot 的堆是可以扩展的.

* 方法区 Method Area:

	JVM 规范把方法区视为堆的一个逻辑部分. 
	主要存放: 类型信息, 常量, 静态变量, 编译缓存.


#### Q: 什么情况下会抛出 `OutOfMemoryError` 和 `StackOverFlowError`?

`StackOverFlowError` 栈溢出, 
* 深递归耗尽栈空间;

`OutOfMemoryError` 内存不足. 
* 当堆空间耗尽后(已经达到最大限制而不能再扩容), 再要求实例化对象将报告内存不足;
* 堆空间耗尽要求扩容, 机器内存不足;
* 对于栈空间可以扩容的 JVM(Hotspot不可对栈扩容), 要求扩容栈空间时, 机器内存不足;
* Direct Memory 请求内存时, 机器内存不足;

#### Q: JVM 如何保证对象创建时Heap的线程安全?

解决线程安全问题一般有乐观锁和悲观锁的方式.
由于对象创建是高频操作, 悲观锁的开销过大, 所以选用乐观锁的方式, 具体来说就是 CAS: Compare and Swap.

另一种方式是为每个线程单独划分一块自用的堆, 即 Thread Local Allocation Buffer, TLAB, 本地线程分配缓冲.
只在初始分配和扩容分配时才需要锁, 在线程内部便没有竞争条件.
