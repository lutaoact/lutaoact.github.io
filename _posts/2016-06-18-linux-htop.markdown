---
layout: post
title:  "进程查看工具htop"
date:   2016-06-18 13:52:39 +0800
categories: linux htop
---

htop命令的出现，在一定程度上取代了top命令的使用。常规的使用方法，网上有很多文章可以参考，这里就不重复了，这里只涉及几个我们经常会接触到的方面。

## 排序

指令：`<F6>`, `<`, `>`
{% highlight sh %}
# 我们最常用的可能就是这两项的排序
PERCENT_CPU #%CPU
PERCENT_MEM #%MEM
{% endhighlight %}

## 设置

指令：`<F2>`

* 如果在显示界面发现每个进程都出现多个重复项，除了PID不同，其它都相同，这应该是主进程生成的线程，如果不需要，可以修改设置中的Display options
{% highlight sh %}
[x] Hide userland process threads
{% endhighlight %}

* 推荐设置
{% highlight sh %}
# 以下为Display options
[x] Tree view
[x] Display threads in a different color
[x] Highlight program "basename"
[x] Highlight large numbers in memory counters
[x] Leave margin around header
[x] Count CPUs from 0 instead of 1
{% endhighlight %}
