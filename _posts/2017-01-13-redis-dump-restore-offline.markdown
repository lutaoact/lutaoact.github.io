---
layout: post
title:  "redis中的dump和restore命令"
date:   2017-01-13 17:52:46 +0800
categories: markdown
---

redis的持久化方案有两个rdb和aof，但这两种方案都是针对全库进行持久化的。

当我们需要将整个数据库迁移的时候就很方便，直接复制相应的文件就可以了。但如果我们只需要迁移指定的某些key的时候，就得换个方法了，尤其当数据库很大的时候，全库迁移是一件很让人头疼的事情。

可以通过dump命令将数据备份到离线文件中，然后再用restore命令恢复数据。这两个命令并非为命令行设计的，所以在使用过程中有一些注意事项。

* 在dump的时候需要使用`--raw`直接存储成为二进制文件
{% highlight text %}
\redis-cli --raw dump key1 > dumpfile
{% endhighlight %}
* 可以通过sublime或其它工具用hexdecimal格式来查看这个二进制文件，可以发现最后一个字节是`0a`，这是换行符，删掉这个换行符，然后保存文件
* 利用restore命令来恢复数据
{% highlight text %}
cat dumpfile | \redis-cli -x restore key2 0
{% endhighlight %}

以上功能也可以通过管道来实现：
{% highlight text %}
\redis-cli --raw dump key1 | head -c-1 | \redis-cli -x restore key2 0
{% endhighlight %}

注：命令签名的反斜杠表示使用redis-cli本身，而避免被alias替代。head命令使用的是GNU版本的，

## 参考链接
* [How to use redis `DUMP` and `RESTORE` (offline)?](http://stackoverflow.com/questions/16127682/how-to-use-redis-dump-and-restore-offline){:target="_blank"}
