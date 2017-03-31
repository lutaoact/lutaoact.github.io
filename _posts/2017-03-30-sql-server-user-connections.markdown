---
layout: post
title:  "SQL Server连接时好时坏的奇怪问题"
date:   2017-03-30 17:50:41 +0800
categories: sql-server sp_configure
---

如果无法定位问题所在，当我们向别人求助时，我们甚至不知道该如何提问。

因为合作商的关系，我们有一台服务器是Windows系统的，运行SQL Server，而团队的所有成员都并不熟悉这套东西。重启了服务器，然后注意到一个问题，数据库连接时好时坏。

我用的是nodejs的[mssql][mssql-doc]模块，非常可恨的是，没有连接成功，也没有报任何错，反正就是什么都没有发生就结束了。

搞这些不熟悉的东西，真是一件让人头疼的事情，但我相信所有的莫名其妙，都必然存在一个被我们忽视的原因。

## 远端Windows服务器上
{% highlight text %}
> netstat -ano | findstr 1433
 TCP    0.0.0.0:1433           0.0.0.0:0              LISTENING       1452
 TCP    127.0.0.1:1433         127.0.0.1:50093        ESTABLISHED     1452
 TCP    127.0.0.1:50093        127.0.0.1:1433         ESTABLISHED     3636
{% endhighlight %}
这说明服务是出于正常监听状态，而且我使用服务器上的SSMS(SQL Server Management Studio)是可以成功连接的。

## 本地linux机器上
{% highlight text %}
$ nc -z msserver 1433
Connection to msserver port 1433 [tcp/ms-sql-s] succeeded!
{% endhighlight %}
这说明端口确实处于正常监听状态。

## 问题定位
我猜想可能是连接用尽，想查看一下当前连接数，可问题是，连接真的用尽了，我甚至没办法新开一个窗口执行sql语句。我查看了数据库服务器的日志，希望找到一些线索。习惯了linux的操作习惯，打算直接找日志文件，后来才发现windows的日志可以直接通过图形界面查看。发现如下内容：
{% highlight sh %}
由于 '4' 用户连接数已达到最大值，因此无法连接。系统管理员可以使用 sp_configure 来提高最大值。该连接已关闭。[客户端: xx.xx.xx.xx]
{% endhighlight %}
感觉很明确了，应该就是数据库允许连接数太小，很容易被占满，所以连接时好时坏。定位了问题，解决方案就呼之欲出了，思路是：`增大数据库允许的用户连接数`。

找了很多方案，但都不成功，而且因为对SQL Server数据库不熟悉，所以操作上也很不方便，直到找到这篇[救命文档][save-my-life-doc]，按照上面所说的操作，结合[另一篇][another-doc]，修改了允许用户的最大连接数为100，问题成功解决。

## 解决方案
{% highlight text %}
C:\> sqlcmd -E #这是windows系统的命令行，由此进入数据库配置shell
1> sp_configure 'show advanced options', 1
2> go
配置选项 'show advanced options' 已从 1 更改为 1。请运行 RECONFIGURE 语句进行安装。
1> reconfigure
2> go
1> sp_configure 'user connections', 100
2> go
配置选项 'user connections' 已从 4 更改为 100。请运行 RECONFIGURE 语句进行安装。
1> exec sp_configure 'show advanced options', 0
2> go
配置选项 'show advanced options' 已从 1 更改为 0。请运行 RECONFIGURE 语句进行安装。
1> reconfigure
2> go
1> exit
{% endhighlight %}
然后重启SQL Server，配置就生效了。

* 查看数据库允许设置的最大连接数，总是返回32767，也就是用户连接数最大可设置为32767
{% highlight text %}
select @@max_connections
{% endhighlight %}
* 查看当前设置的最大连接数
{% highlight text %}
select value from master.dbo.sysconfigures where [config] = 103
{% endhighlight %}
* 查看各个用户的当前连接数
{% highlight text %}
select loginame, count(1) as Nums from sys.sysprocesses group by loginame order by 2 desc
{% endhighlight %}

## 参考链接
* [Error while connecting to SQL Server – "Could not connect because the maximum number of '1' user connections has already been reached."](https://blogs.msdn.microsoft.com/dataaccesstechnologies/2015/07/21/error-while-connecting-to-sql-server-could-not-connect-because-the-maximum-number-of-1-user-connections-has-already-been-reached/){:target="_blank"}
* [How to use SP_CONFIGURE in SQL Server](https://straightpathsql.com/archives/2009/10/how-to-use-sp_configure-in-sql-server/){:target="_blank"}
* [由于 '*' 用户连接数已达到最大值，因此无法连接。](http://www.lofter.com/tag/%E7%94%A8%E6%88%B7%E8%BF%9E%E6%8E%A5%E6%95%B0%E5%B7%B2%E8%BE%BE%E5%88%B0%E6%9C%80%E5%A4%A7){:target="_blank"}
* [MS SQL专用管理员连接DAC](http://www.cnblogs.com/kerrycode/p/3344085.html){:target="_blank"}


[mssql-doc]: https://github.com/patriksimek/node-mssql/blob/1893969195045a250f0fdeeb2de7f30dcf6689ad/README.md
[save-my-life-doc]: https://blogs.msdn.microsoft.com/dataaccesstechnologies/2015/07/21/error-while-connecting-to-sql-server-could-not-connect-because-the-maximum-number-of-1-user-connections-has-already-been-reached/
[another-doc]: http://www.lofter.com/tag/%E7%94%A8%E6%88%B7%E8%BF%9E%E6%8E%A5%E6%95%B0%E5%B7%B2%E8%BE%BE%E5%88%B0%E6%9C%80%E5%A4%A7
