---
layout: post
title:  "nethogs: 按进程实时统计网络流量"
date:   2017-04-11 17:30:34 +0800
categories: mongodb auth
---

当服务器流量突然飙升时，往往需要查看系统实时流量来定位原因。nethogs可以根据进程来查看实时流量。

centos中安装：
{% highlight sh %}
sudo yum -y install nethogs
{% endhighlight %}

监控流量，执行nethogs命令需要sudo权限
{% highlight sh %}
nethogs eth1
{% endhighlight %}

监控展示页面的一些快捷键：
{% highlight sh %}
m  #修改显示单位
r  #按接收流量排序 RECEIVED
s  #按发送流量排序 SENT
q  #退出命令提示符
{% endhighlight %}

## 参考链接
* [nethogs github page](https://github.com/raboof/nethogs){:target="_blank"}
