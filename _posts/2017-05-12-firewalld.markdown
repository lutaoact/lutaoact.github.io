---
layout: post
title:  "firewalld依赖python2，莫名的启动失败终于找到原因"
date:   2017-05-12 17:40:06 +0800
categories: firewalld
---

centos7中遇到的问题，firewalld无法启动：
{% highlight sh %}
systemctl start firewalld
{% endhighlight %}
报错信息如下：
{% highlight text %}
Job for firewalld.service failed because the control process exited with error
code. See "systemctl status firewalld.service" and "journalctl -xe" for details
{% endhighlight %}
我执行`journalctl -f`监控日志输出，得到以下信息：
{% highlight text %}
polkitd[6524]: Registered Authentication Agent for unix-process:3411:2850658888 (system bus name :1.347925 [/usr/bin/pkttyagent --notify-fd 5 --fallback], object path /org/freedesktop/PolicyKit1/AuthenticationAgent, locale zh_CN.UTF-8)
systemd[1]: Starting firewalld - dynamic firewall daemon...
systemd[1]: firewalld.service: main process exited, code=exited, status=1/FAILURE
systemd[1]: Failed to start firewalld - dynamic firewall daemon.
systemd[1]: Unit firewalld.service entered failed state.
systemd[1]: firewalld.service failed.
polkitd[6524]: Unregistered Authentication Agent for unix-process:3411:2850658888 (system bus name :1.347925, object path /org/freedesktop/PolicyKit1/AuthenticationAgent, locale zh_CN.UTF-8) (disconnected from bus)
{% endhighlight %}
感觉像是什么授权问题，可事后证明，这真的是一种误导，在网上搜索解决方案的时候，找到了一篇文档，就是参考链接的第一篇，这是讲mysql的，文中的一句话给了我启示：
{% highlight sh %}
journalctl -xe命令查看服务启动失败的原因往往并不如人意，反而给了一种错误的暗示，
以为这个跟系统有关。其实，通过查看服务的日志，往往更能清晰的知道服务启动失败的原因。
{% endhighlight %}
服务配置文件`/usr/lib/systemd/system/firewalld.service`中提到会把日志输出到`/var/log/messages`文件中，查看之后并没有发现更多有用的信息。
{% highlight sh %}
systemd: Starting firewalld - dynamic firewall daemon...
systemd: firewalld.service: main process exited, code=exited, status=1/FAILURE
systemd: Failed to start firewalld - dynamic firewall daemon.
systemd: Unit firewalld.service entered failed state.
systemd: firewalld.service failed.
{% endhighlight %}
我需要更详细的日志信息，探索德治可以打开debug信息，编辑`/etc/sysconfig/firewalld`，将配置改为：
{% highlight text %}
FIREWALLD_ARGS=--debug=10
{% endhighlight %}
然后我还修改`/usr/lib/systemd/system/firewalld.service`，修改了2行，这个文件貌似是不应该修改的，应该复制一份到`/etc/systemd/system`目录下再修改，下次注意：
{% highlight text %}
StandardOutput=/var/log/firewalld
StandardError=/var/log/firewalld
{% endhighlight %}
然后需要重新载入服务：
{% highlight sh %}
systemctl daemon-reload
{% endhighlight %}
之后再重新启动firewalld，发现日志`/var/log/messages`中有了新变化，多了这个内容：
{% highlight text %}
firewalld: Traceback (most recent call last):
firewalld: File "/usr/sbin/firewalld", line 29, in <module>
firewalld: import dbus
firewalld: ImportError: No module named 'dbus'
{% endhighlight %}
这玩意儿怎么这么面熟呢？感觉在哪里见过。想起来了，上次`yum-config-manager`这个命令也报过类似的错误，原因是系统python默认指向的是python3，而实际依赖的是python2。

我迅速修改`/usr/sbin/firewalld`文件，将首行的`/usr/bin/python`改为`/usr/bin/python2`，问题顺利解决。

感觉自己又长进了不少，总结自己每一次解决问题的经历，也算是一种复盘，希望能指导自己不断进步。

最后，`journalctl`真不靠谱。

## 参考链接
* [CentOS 7下MySQL服务启动失败的解决思路](http://www.cnblogs.com/ivictor/p/5146247.html){:target="_blank"}
* [Can logging be enabled in FirewallD](https://unix.stackexchange.com/questions/114734/can-logging-be-enabled-in-firewalld){:target="_blank"}
