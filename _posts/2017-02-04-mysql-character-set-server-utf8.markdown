---
layout: post
title:  "mysql5.6默认字符集设置及过程中踩到的坑"
date:   2017-02-04 17:05:35 +0800
categories: mysql character server utf8
---

修改默认字符集，是个很常见的需求，应该也不难搞，可偏偏过程比较神奇。

`MACOS X Yosemite`系统，使用mysql官网下载的dmg文件，直接安装，安装目录为`/usr/local/mysql`，即为basedir，配置文件my.cnf即在basedir中。

## MySQL Preference Pane
利用`MySQL Preference Pane`，也就是mac的`系统偏好设置`里的配置面板，实现管理mysqld，下文中的重启均是利用此管理工具。
![mysql配置面板](/assets/mysql-preference-pane.jpg)

它的启动配置文件路径为：
{% highlight text %}
/Library/LaunchDaemons/com.oracle.oss.mysql.mysqld.plist
{% endhighlight %}

mysqld的启动参数包含在上述配置文件中：
{% highlight sh %}
/usr/local/mysql/bin/mysqld --user=_mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --plugin-dir=/usr/local/mysql/lib/plugin --log-error=/usr/local/mysql/data/mysqld.local.err --pid-file=/usr/local/mysql/data/mysqld.local.pid
{% endhighlight %}

## my.cnf
修改my.cnf，增加默认字符集配置，在`[client]`和`[mysqld]`区块中都增加`default-character-set=utf8`。然后重启服务器，结果，字符集没有任何变化。

{% highlight sh %}
mysqld --print-defaults # 查看默认启动参数
{% endhighlight %}

修改配置文件并没有改变以上命令的输出，由此可知，`服务器根本就没有读取该配置文件`。

既然服务器没有自动读取，那我希望通过手动提供参数来实现，通过以下命令求助：
{% highlight sh %}
mysqld --verbose --help
{% endhighlight %}
发现输出中包含以下内容：
{% highlight text %}
Default options are read from the following files in the given order:
/etc/my.cnf /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf ~/.my.cnf
{% endhighlight %}
恍然大悟，根本就没有读到my.cnf的路径/usr/local/mysql/my.cnf，修复方式如下：
{% highlight sh %}
sudo mkdir etc
sudo ln -s /usr/local/mysql/my.cnf /usr/local/mysql/etc/
{% endhighlight %}

配置文件成功读取，不过又遇到了新的问题~~

## character-set-server = utf8
启动过程中报错：
{% highlight text %}
/usr/local/mysql/bin/mysqld: unknown variable 'default-character-set=utf8'
{% endhighlight %}
原来是mysql5.0之后，这个配置选项已经废弃，直接启用新的配置选项即可：
{% highlight text %}
character-set-server = utf8
collation-server = utf8_unicode_ci
init_connect = 'SET collation_connection = utf8_unicode_ci; SET NAMES utf8;'
skip-character-set-client-handshake
{% endhighlight %}
重启服务器，然后连接，在mysql shell中，使用以下命令检验：
{% highlight sh %}
mysql> show variables like '%character%';
+--------------------------+-----------------------------------------------------------+
| Variable_name            | Value                                                     |
+--------------------------+-----------------------------------------------------------+
| character_set_client     | utf8                                                      |
| character_set_connection | utf8                                                      |
| character_set_database   | utf8                                                      |
| character_set_filesystem | binary                                                    |
| character_set_results    | utf8                                                      |
| character_set_server     | utf8                                                      |
| character_set_system     | utf8                                                      |
| character_sets_dir       | /usr/local/mysql-5.6.35-macos10.12-x86_64/share/charsets/ |
+--------------------------+-----------------------------------------------------------+

mysql> show variables like '%collation%';
+----------------------+-----------------+
| Variable_name        | Value           |
+----------------------+-----------------+
| collation_connection | utf8_general_ci |
| collation_database   | utf8_unicode_ci |
| collation_server     | utf8_unicode_ci |
+----------------------+-----------------+
{% endhighlight %}


## 参考链接
* [How to change MySQL default character-set to UTF8](http://kosalads.blogspot.sg/2013/03/mysql-55-how-to-change-mysql-default.html){:target="_blank"}
* [MySQL Preference Pane](http://apple.stackexchange.com/questions/199914/mysql-preference-pane-is-specifying-a-port-number-when-it-runs-mysqld){:target="_blank"}
