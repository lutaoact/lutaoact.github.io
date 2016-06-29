---
layout: post
title:  "mongo bulk batches need to be under 16MB"
date:   2016-06-29 16:43:30 +0800
categories: mongodb mongoimport
---

在执行mongoimport或者mongorestore命令的时候，如果导入的是一些大文件，可能会遇到以下一些错误：

* BSONObj size: XXX is invalid
* restore error: insertion error: EOF
* Restore error: false invalid document size
* Failed: lost connection to server

这些错误差不多都是因为导入工具限制了最大的bulk batch size而引起的，mongo要求必须小于16MB。

注意：max bson doc size值也是16MB，它俩恰好相等，但它们是不同的东西。max bson doc size用来限制单个文档的尺寸，而bulk batch size用来限制在导入数据过程中的内存使用尺寸。

参数`--batchSize`用来限制每次加载的doc数量，默认貌似是10000，如果你的单个文档超过了1600字节(也就是16MB / 10000)，那就很有可能超过限制而导致导入失败。

### 解决方法：

* 给参数`--batchSize`传递一个更小的值。具体的值取决于你实际的文档大小，所以没什么可以推荐的值，在我的应用中，我把这个值改为10，才让程序得以正常执行。有一个问题还是应该提一下，就是这个参数并没有在`--help`中展示出来，所以使用的时候还是要谨慎。
{% highlight sh %}
--batchSize=[num] #默认为10000，如果文档太大，
{% endhighlight %}
* 使用参数`-j, --numInsertionWorkers=<number>`增加执行线程，默认为1，这个数值可以等于或小于机器的CPU核数。
{% highlight sh %}
--numInsertionWorkers=4
{% endhighlight %}

以上是整理了我在实际工作中遇到的问题，并最终找到的解决方案，希望能对更多的人有所帮助。
