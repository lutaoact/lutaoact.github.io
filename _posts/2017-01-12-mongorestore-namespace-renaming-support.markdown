---
layout: post
title:  "mongorestore命令增加对修改命名空间的支持"
date:   2017-01-12 16:59:40 +0800
categories: mongodb mongorestore
---

支持从mongodb 3.4开始

{% highlight text %}
$ mongorestore --version
mongorestore version: r3.4.0
git version: 3cc9a07766fb55de63e81a13e72f3c5a7c07f477
Go version: go1.7.4
   os: darwin
   arch: amd64
   compiler: gc
OpenSSL version: OpenSSL 1.0.2j  26 Sep 2016
{% endhighlight %}

通过`mongorestore --help`来查看相关选项变化：

* 新增命令行选项
{% highlight text %}
--nsExclude=<ns-pattern>  exclude matching namespaces
--nsInclude=<ns-pattern>  include matching namespaces
--nsFrom=<ns-pattern>     rename matching namespaces, must have matching nsTo
--nsTo=<ns-pattern>       rename matched namespaces, must have matching nsFrom

--dryRun                  recommended with verbosity
{% endhighlight %}
注：`--nsExclude`和`--nsInclude`都可以多次出现，也可以结合使用，`--nsInclude`会在`--nsExclude`之前处理。在命名空间模式中，支持`*`作为通配符。`--nsFrom`和`--nsTo`必须成对出现。

* deprecated选项:
{% highlight sh %}
--db, --collection, --excludeCollection, --excludeCollectionsWithPrefix
{% endhighlight %}

## 使用示例
{% highlight sh %}
# 将数据库app重命名为app-dev，所有的表名称保持不变
mongodump --db app --archive | mongorestore --nsFrom='app.*' \
                                            --nsTo='app-dev.*' --archive
# 将远程数据库同步到本地则可以用类似方式来完成，使用--gzip来减少网络数据传输
ssh dev 'mongodump --db app --archive --gzip' | mongorestore \
                    --nsFrom='app.*' --nsTo='app-dev.*' --archive --gzip

# 将数据库app中带有user前缀的表都转移到app-dev中，功能真是太强大了
mongodump --db app --archive | mongorestore --nsInclude='*.user*' \
                           --nsFrom='app.*' --nsTo='app-dev.*' --archive

# 使用匹配变量实现更复杂的功能，用双$符号的形式'$var$'来赋值匹配变量
# --nsFrom '$db$.user$stuff$' --nsTo 'user.$stuff$.$db$'
# --nsFrom 'test_$stack$.$coll$' --nsTo 'recover.$stack$.$coll$'
mongodump --db app --archive | mongorestore --nsInclude='*.user*' \
      --nsFrom='$db$.use$stuff$' --nsTo='$db$xxx.$stuff$.user' --archive
# 结果：app.user和app.user2 => appxxx.r.user和app.r2.user
# 功能太强大，慢慢学习吧
{% endhighlight %}

## 参考链接
* [mongorestore namespace renaming support](https://jira.mongodb.org/browse/TOOLS-1234)
