---
layout: post
title:  "linux服务器系统性能分析"
date:   2017-05-11 19:39:50 +0800
categories: iotop ps vmstat iostat pidof pidstat sar taskset
---

案例：

1. 系统内存剩余，CPU未满，但IO很高，负载也很高。有时候可能是因为系统重启，大量数据需要从硬盘读到内存中，所以此时内存未满，但负载很高，因为CPU的大多数时间都在等待IO。


## 测试基于centos

* iotop
{% highlight sh %}
# yum install -y iotop
# --only/-o see current processes or threads actually doing I/O,
# instead of watching all processes or threads.
iotop --only/-o
{% endhighlight %}


* ps
{% highlight sh %}
ps -o user,pid,ppid,psr,cmd -p $(pidof mongod)
ps -o user,pid,ppid,psr,cmd -p 2404 2353 2286 2251 2132
输出：
USER       PID  PPID PSR CMD
centos    2132     1   5 mongod --config /etc/mongod-info-pdt.conf
{% endhighlight %}
注：用-o设置需要显示的字段，-p指定pid列表

{% highlight text %}
ps -eLF
输出：
UID   PID PPID  LWP C NLWP     SZ    RSS PSR STIME TTY     TIME CMD
user 2132    1 2132 0   29 291749 792372 5   May10 ?   00:01:53 mongod
{% endhighlight %}
注：LWP为线程id，NLWP为线程数，PSR为运行该进程的CPU编号。


* vmstat
{% highlight text %}
vmstat 2 100 #每2秒输出一次，共100次
输出：
procs -----------memory---------- --swap-- ---io-- --system-- -----cpu-----
r  b  swpd   free   buff  cache   si   so   bi  bo   in   cs  us sy id wa st
0  0     0 418652 462788 29497160  0    0  166  43   46   35   1  1 92  6  0
{% endhighlight %}
注：in为每秒中断（interrupt）次数，cs为每秒上下文切换（context switch）次数，wa为IO等待的CPU时间占比。


* iostat
{% highlight sh %}
iostat
iostat -x
{% endhighlight %}
注：-x显示详细信息，查看每个硬盘的IO情况



* pidstat
{% highlight sh %}
pidstat -w #查看进程上下文切换情况
输出：
15时38分54秒       PID   cswch/s nvcswch/s  Command
15时38分54秒      2251     99.00      0.00  mongod
{% endhighlight %}

{% highlight sh %}
pidstat -wt #线程信息也一并列出
15时42分58秒      TGID       TID   cswch/s nvcswch/s  Command
15时42分58秒      2132         -     99.51      0.00  mongod
15时42分58秒         -      2132     99.51      0.00  |__mongod
15时42分58秒         -      2136      9.80      0.00  |__mongod
{% endhighlight %}
注：我们在vmstat中看到的总的上下文切换，往往是所有线程加起来的数，而不是进程加起来的数

* sar
{% highlight sh %}
sar -w 3 1 #查看总的上下文切换情况，跟vmstat输出中的cs字段差不多
15时45分35秒    proc/s   cswch/s
15时45分38秒      0.00   5431.42
平均时间:      0.00   5431.42
{% endhighlight %}

* taskset
{% highlight sh %}
taskset -cp 6389 #查看进程6389当前的绑定状况
taskset -cp 0,1 6389 #将进程绑定在指定0和1号CPU上运行，CPU编号从0开始
{% endhighlight %}
{% highlight sh %}
# 在进程启动时绑定，则该进程产生的所有线程都在指定CPU上运行：
taskset 0x00000010 mongod --config /etc/mongodReplSet.conf #设定4号CPU
{% endhighlight %}

* pidof
{% highlight sh %}
pidof mongod #列出所有mongod进程，插件进程详细信息使用ps [PID]
{% endhighlight %}

## 参考链接
* [iostat 监视I/O子系统](http://linuxtools-rst.readthedocs.io/zh_CN/latest/tool/iostat.html){:target="_blank"}
* [Linux vmstat命令实战详解](http://www.cnblogs.com/ggjucheng/archive/2012/01/05/2312625.html){:target="_blank"}
* [进程上下文频繁切换导致load average过高](http://www.361way.com/linux-context-switch/5131.html){:target="_blank"}
