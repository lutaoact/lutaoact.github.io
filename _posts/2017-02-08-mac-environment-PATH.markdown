---
layout: post
title:  "mac中PATH环境变量的管理"
date:   2017-02-08 13:45:02 +0800
categories: mac path
---

mac系统中PATH环境变量的预置值是由`/etc/paths`决定的，每个路径一行，可以按照需要调整路径顺序。

{% highlight text %}
/usr/local/bin
/usr/bin
/bin
/usr/sbin
/sbin
{% endhighlight %}

{% highlight sh %}
/usr/libexec/path_helper -s #打印当前的PATH配置
{% endhighlight %}
