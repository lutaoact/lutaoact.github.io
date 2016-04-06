---
layout: post
title:  "sysstat相关"
date:   2016-03-09 14:10:47 +0800
categories: linux sar
---

## sysstat

### 服务器运行状况监控软件

#### centos中使用yum安装
{% highlight sh %}
sudo yum install -y sysstat #安装sar命令
{% endhighlight %}

#### Install Sysstat from Source
* [下载地址](http://sebastien.godard.pagesperso-orange.fr/download.html)
* 安装：
{% highlight sh %}
wget http://perso.orange.fr/sebastien.godard/sysstat-11.2.1.1.tar.xz
tar xvfJ sysstat-11.2.1.1.tar.xz
cd sysstat-11.2.1.1
./configure --prefix=/usr --enable-install-cron
make
sudo make install
{% endhighlight %}

#### 功能介绍
* 使用`crontab`收集统计数据
  * `/usr/lib/sa/sa1` 数据存储路径为`/var/log/sa/saXX`，XX为日期。
  * `/usr/lib/sa/sa2` 数据存储路径为`/var/log/sa/sarXX`，XX为日期。
{% highlight sh %}
#/etc/cron.d/sysstat
*/10 * * * * root /usr/lib64/sa/sa1 1 1
7 0 * * * root /usr/lib64/sa/sa2 -A
{% endhighlight %}


#### 相关命令
{% highlight sh %}
sar -V #查看version
{% endhighlight %}
1. CPU Usage of ALL CPUs (`sar -u`)
    * `sar -u 1 3`
    * `sar -u ALL`
    * `sar -u ALL 1 3`
    * `sar -u -f /var/log/sa/sa10`
2. CPU Usage of Individual CPU or Core (`sar -P`)
    * `sar -P ALL`
    * `sar -P ALL 1 3`
    * `sar -P 1`
    * `sar -P 1 1 3`
    * `sar -P ALL -f /var/log/sa/sa10`
3. Memory Free and Used (`sar -r`)
4. Swap Space Used (`sar -S`)
5. Overall I/O Activities (`sar -b`)
6. Individual Block Device I/O Activities (`sar -d`)


[参考链接](http://www.thegeekstuff.com/2011/03/sar-examples/)（这是一篇很好的文章）
