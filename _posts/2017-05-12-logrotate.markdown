---
layout: post
title:  "logrotate日志轮转"
date:   2017-05-12 16:18:45 +0800
categories: logrotate
---

centos6中，默认的logrotate配置文件为`/etc/logrotate.conf`，启动时间设置在`/etc/anacrontab`中，默认是每天凌晨3点多执行，并不绝对准确，因为有一个随机的波动时间。大家有兴趣的可以自行查阅。

如果希望进行更灵活的启动时间和内容配置，可以通过自行创建配置文件，并添加相应的crontab运行指令来实现。

## 应用实例
* nginx日志的轮转
{% highlight text %}
/data/log/nginx.my.access.log {
  daily
  dateext
  missingok
  rotate 30
  compress
  delaycompress
  notifempty
  create 640 nginx root
  sharedscripts
  postrotate
    if [ -f /var/run/nginx.pid ]; then
      kill -USR1 `cat /var/run/nginx.pid`
    fi
  endscript
}
{% endhighlight %}
crontab中的配置如下：
{% highlight sh %}
59 23 * * * /usr/sbin/logrotate -f /etc/logrotate.nginx.my.conf
# 每天的23点59分执行指定的日志轮转
{% endhighlight %}
如果执行过程中报错`parent directory has insecure permissions`，这主要文件所在的目录所有者并不是root导致，可以通过指定运行命令的用户和组来解决权限问题，在配置中增加如下指令：
{% highlight sh %}
su [user] [group]
# user和group是日志文件的实际用户和组信息
{% endhighlight %}

## 参考链接
* [Why does my CentOS logrotate run at random times?](https://serverfault.com/questions/454118/why-does-my-centos-logrotate-run-at-random-times){:target="_blank"}
