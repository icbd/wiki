---
layout: post
title:  "理解UNIX进程"读书笔记
date:   2017-09-01
categories: notes
---

# Working with Unix processes

![](https://img1.doubanio.com/lpic/s26592239.jpg)

# Ch1 引言

Resque Unicorn

# Ch2 基础

程序不可以直接访问内核，所有的通信都是通过系统调用来完成的。系统调用为内核和用户空间搭建了桥梁。它规定了程序与计算机硬件之间所允许发生的一切交互。

所有的程序都运行在用户空间。系统调用允许用户空间程序通过内核间接地与计算机硬件进行交互。

# Ch3 PID

$$ Process.pid

查看 ps -p pid

# Ch4 PPID

Process.ppid

# Ch5 文件描述符

Unix中一切都是文件.

打开资源获得其文件描述符,进程结束时资源会一同关闭.文件描述符只存在于所属进程中,不会与其他进程共享.

所分配的文件描述符编号是尚未使用的最小的数值.资源一旦关闭，对应的文件描述符编号就回收重用.

文件描述符只是用来跟踪打开的资源，已经关闭的资源是没有文件描述符的。

## 标准流

STDIN.fileno #0

STDOUT.fileno #1

STDERR.fileno #2

# Ch6 资源限制

系统资源限制:

Process.getrlimit(:NOFILE)

#[256, 9223372036854775807]

#[软限制, 硬限制]

硬限制的值等同于 Process::RLIM_INFINITY, 即表示无限大.

Process.setrlimit(:NOFILE, 2048, 4096)

 [http://ruby-doc.org/core-2.4.1/Process.html#method-c-setrlimit](http://ruby-doc.org/core-2.4.1/Process.html#method-c-setrlimit)

# Ch7 环境变量

所有进程都从其父进程处继承环境变量。

比起解析命令行选项，使用环境变量的开销通常更小一些。

    $ uid=CbdFocus irb
    >> ENV['uid']
    => "CbdFocus"

ENV 是不完全的Hash

# Ch8 参数数组

ARGV是数组, 可在运行时修改.

    # main.rb
    p ARGV
    p ARGV.include?("-c") && ARGV[ARGV.index("-c") + 1]

    #$ ruby main.rb -c diy.conf
    #["-c", "diy.conf"]
    #"diy.conf"

# Ch9 进程名

进程名,全局变量: $PROGRAM_NAME($0)

# Ch10退出码

退出码0代表顺利结束

exit,正常退出(0),执行at_exit块

exit!,异常退出(1),不执行at_exit块

abort,异常退出(1),执行at_exit块,打印到STDERR

raise,抛异常,如果没有被捕获就异常退出(1),执行at_exit块,打印到STDERR

# Ch11 fork

 **子进程从父进程处继承了其所占用内存中的所有内容，以及所有属于父进程的已打开的文件描述符。**

子进程是一个全新的进程，所以它拥有自己唯一的pid。

子进程fork返回nil,父进程fork返回子进程pid.

    p "[#{Process.pid}]start at parent"

    fork do
     p "[#{Process.pid}]only at son and exit"
    end

    p "[#{Process.pid}]only at parent"

    #"[1837]start at parent"
    #"[1837]only at parent"
    #"[1838]only at son and exit"

# Ch12 孤儿进程

 父进程结束后,子进程安然无恙.

    p "[#{Process.pid}]start"

    fork do
     3.times do
     sleep 1
     p "[#{Process.pid}]im a orphan"
     end
    end

    abort "[#{Process.pid}]parent process died."

    #$ ruby main.rb
    #"[1905]start"
    #[1905]parent process died.
    #"[1906]im a orphan"
    #"[1906]im a orphan"
    #"[1906]im a orphan"

守护进程是一种长期运行的进程，为了能够一直保持运行，它们有意作为孤儿进程存在。

# Ch13 CoW

单纯的标记-清除方式的垃圾回收使CoW失效.(首次标记即改动了所有对象)

# Ch14 wait

等待子进程退出:

(内核将退出的进程信息加入队列,父进程总能依次接收退出消息,即使子进程已经退出了很久.)

    # Process.wait() -> fixnum
    # Process.wait(pid=-1, flags=0) -> fixnum
    # Process.waitpid(pid=-1, flags=0) -> fixnum


    # Process.wait2(pid=-1, flags=0) -> [pid, status]
    # Process.waitpid2(pid=-1, flags=0) -> [pid, status]


    # Process.waitall -> [ [pid1,status1], ...]

    son_pid = fork do
     p "son..."
     sleep 1
    end

    p son_pid
    p Process.wait

    __END__
    1221
    "son..."
    1221

    # > 0:: Waits for the child whose process ID equals _pid_.
    #
    # 0:: Waits for any child whose process group ID equals that of the
    # calling process.
    #
    # -1:: Waits for any child process (the default if no _pid_ is
    # given).
    #
    # < -1:: Waits for any child whose process group ID equals the absolute
    # value of _pid_.

成为 master/worker 或 preforking

# Ch15 zombie

僵尸进程:内核将已经退出的子进程状态信息加入队列,如果不调用Process.wait系列方法,这些状态信息将一直占用内核资源.

Process.detach(sonPID) #清除该PID在退出之后遗留在内核中的状态信息.

# Ch16 unix signal

信号投递不可靠.

    Signal.list
    => {"EXIT"=>0, "HUP"=>1, "INT"=>2, "QUIT"=>3, "ILL"=>4, "TRAP"=>5, "ABRT"=>6, "IOT"=>6, "EMT"=>7, "FPE"=>8, "KILL"=>9, "BUS"=>10, "SEGV"=>11, "SYS"=>12, "PIPE"=>13, "ALRM"=>14, "TERM"=>15, "URG"=>16, "STOP"=>17, "TSTP"=>18, "CONT"=>19, "CHLD"=>20, "CLD"=>20, "TTIN"=>21, "TTOU"=>22, "IO"=>23, "XCPU"=>24, "XFSZ"=>25, "VTALRM"=>26, "PROF"=>27, "WINCH"=>28, "USR1"=>30, "USR2"=>31, "INFO"=>29}

发送信号:

Process.kill(:INT, 1200) # 向pid为1200的进程发送:INT ("INT" / :SIGINT / "SIGINT") 的信号.

重定义信号:

    # 重新定义接收到:USR1信号时的行为
    Signal.trap(:USR1) do |signo|
    	# redefine response of :USR1 Signal
    end


    # 忽略对INT信号的捕获
    Signal.trap(:INT, "IGNORE")


    # 考虑多处定义
    old_handler = Signal.trap(:INT) do
    	old_handler.call if old_handler.response_to?(:call)
    end

# Ch17 IPC

通道是单向的.

只要w不关闭, r就会一直阻塞等待.w关闭是写入EOF,r一直读直到读到EOF.

    r, w = IO.pipe
    w.write("Pied")
    w.write("Piper")
    w.close

    p r.read
    p r.read
    __END__
    $ ruby -v main.rb
    ruby 2.3.4p301 (2017-03-30 revision 58214) [x86_64-darwin16]
    "PiedPiper"
    ""

fork时文件描述符也会被复制. 由于IO管道是单向的,必须把不需要的管道关闭.

    r, w = IO.pipe

    pid = fork do
     puts "this is son process."
     r.close

     5.times do
     w.write "#{Time.now}\n"
     sleep 1
     end
    end

    puts "this is father."
    w.close
    Process.detach pid
    while msg = r.gets
     puts msg
    end

    __END__
    $ ruby -v main.rb
    ruby 2.3.4p301 (2017-03-30 revision 58214) [x86_64-darwin16]
    this is father.
    this is son process.
    2017-09-01 13:46:56 +0800
    2017-09-01 13:46:57 +0800
    2017-09-01 13:46:58 +0800
    2017-09-01 13:46:59 +0800
    2017-09-01 13:47:00 +0800

Unix套接字是一种只能用于在同一台物理主机中进行通信的套接字。它比TCP套接字快得多，非常适合用于IPC。

在管道中无法使用消息, 在Unix套接字中可以.

管道是单向的，套接字对是双向的.

    require 'socket'

    Maxlen = 1000
    s1, s2 = Socket.pair(:UNIX, :DGRAM, 0)


    pid1 = fork do
     s2.close
     s1.send "hi", 0
     sleep 1
     s1.send "hello", 0
     sleep 1
     s1.send "world", 0
     sleep 1
     # s1.send "!", 0
    end

    pid2 = fork do
     s1.close

     3.times do |i|
     msg = s2.recv(Maxlen)
     puts "#{i}: #{msg}" if msg
     end
    end



    Process.detach pid1
    Process.wait pid2
    __END__
    $ ruby -v main.rb
    ruby 2.3.4p301 (2017-03-30 revision 58214) [x86_64-darwin16]
    0: hi
    1: hello
    2: world

# Ch18 守护进程

    def daemonize_app
     if RUBY_VERSION < "1.9"
     exit if fork

    		#该进程变成一个新会话的会话领导;该进程变成一个新进程组的组长;该进程没有控制终端
     Process.setsid

    		#再次衍生,不再是会话领导和进程组组长
     exit if fork

    	 #切换工作目录
     Dir.chdir "/"

    		# 忽略标准输入输出, 但保持其可用不报错
     STDIN.reopen "/dev/null"
     STDOUT.reopen "/dev/null", "a"
     STDERR.reopen "/dev/null", "a"
     else
     Process.daemon
     end
    end

fork 在父进程返回子进程pid, 在子进程返回nil.

孤儿进程的ppid为1(init).

# Ch19 终端进程

exec将当前进程转变成另外一个进程, 然后就回不来了.

把字符串传递给 `exec` ，它实际上会启动一个shell进程，然后再将这个字符串交由shell解释。传递一个数组的话，它会跳过shell，直接将此数组作为新进程的 `ARGV` 。

# Ch20 尾声

与Unix进程打交道事关两件事：抽象和通信。