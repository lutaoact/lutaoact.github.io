---
layout: post
title:  "偶然所得：命令行查看一个已启动进程的STDOUT"
date:   2017-03-10 18:21:59 +0800
categories: cloud sync
---

首先，感谢伟大的stackoverflow。

有一个后台进程已经运行了5个小时了，我想看一下它是不是还在运行。程序输出重定向到了一个文件中，可无奈的是，还有其它正在运行的进程也是输出到这个文件中的，所以我无法仅仅通过文件中有新的内容增加来判断一个程序是否运行，所以我很需要一个方法能帮我直接监控一个指定进程的输出。

直接上方案：
{% highlight sh %}
strace -ewrite -p $PID
strace -ewrite -p $PID 2>&1 | grep 'write(1,' #过滤标准输出的内容
{% endhighlight %}
`strace`这个程序很神奇，我还未有空深入研究，不过看大致输出，它是把所有的写文件句柄的日志都输出了，所以如果希望看标准输出，可以通过`grep 'write(1,'`来过滤，我猜那个`1`应该表示标准输出的句柄编号。输出的时候还有大片大片的其它数值，估计指代的是程序打开的其它文件句柄，看到了写数据库的一些信息。

有空的时候应该好好研究一下这个程序。

## 参考链接
* [Redirect STDERR / STDOUT of a process AFTER it's been started, using command line?](http://stackoverflow.com/questions/593724/redirect-stderr-stdout-of-a-process-after-its-been-started-using-command-lin){:target="_blank"}
