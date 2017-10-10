---
layout: post
title:  "mongodb的upsert操作"
date:   2017-10-09 18:31:56 +0800
categories: mongodb upsert
---

mongodb的update操作调用形式如下：
{% highlight text %}
db.collection.update(query, update, options)

db.collection.update(
   <query>,
   <update>,
   {
     upsert: <boolean>,
     multi: <boolean>,
     writeConcern: <document>,
     collation: <document>
   }
)
{% endhighlight %}
upsert是可选参数，如果设为true，当没有doc匹配查询条件时，会新建doc。默认值为false，在没有找到匹配时，不会插入文档。

## upsert的具体行为
如果upsert为true，并且没有doc匹配查询条件，`update()`会插入一个新doc。

新doc的创建基于以下内容：

1. 如果`<update>`参数是一个替换doc（即只包含配对的字段和值），则新doc基于`<update>`参数的内容创建。如果`<query>`和`<update>`参数都没有指定`_id`字段，MongoDB会为新doc添加一个ObjectId类型的`_id`字段。

2. 如果`<update>`参数包含`更新操作符`表达式，则新doc由`<update>`和`<query>`参数的内容共同决定。`update()`操作会先基于`<query>`参数中的等值语句创建一个基础doc，然后将`<update>`参数中的更新操作应用上去。`<query>`参数中的比较操作不会包含在新doc中。

如果upsert为true，并且根据查询条件找到了匹配文档，那么`update()`就只执行更新操作。

## 参考链接
* [db.collection.update()](https://docs.mongodb.com/manual/reference/method/db.collection.update/){:target="_blank"}
