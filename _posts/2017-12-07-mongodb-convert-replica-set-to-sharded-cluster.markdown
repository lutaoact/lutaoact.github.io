---
layout: post
title:  "将mongodb复制集转换为shard集群"
date:   2017-12-07 20:49:43 +0800
categories: mongodb replSet shard
---

## 1. 假设replica set使用以下配置文件启动
{% highlight sh %}
storage:
  dbPath: /data/replSet/mongo${1}
  journal:
    enabled: true
  engine: wiredTiger

systemLog:
  destination: file
  path: /data/log/mongod${1}.log
  logAppend: true

net:
  port: 2800${1}
  bindIp: 127.0.0.1

processManagement:
  fork: true
  pidFilePath: /data/tmp/mongod${1}.pid

replication:
  replSetName: ${2}
{% endhighlight %}
注：`${1}`和`${2}`根据自己的实际情况赋值。

假设我们启动三节点复制集，监听以下端口28001、28002、28003，复制集名称为`rs0`，启动完成后，需要对复制集进行初始化：
{% highlight sh %}
# 连接任一节点
mongo 127.0.0.1:28001
{% endhighlight %}
{% highlight javascript %}
// 在mongo shell中，执行以下代码：
rs.initiate({
  _id: 'rs0',
  members: [
    {_id: 0, host: '127.0.0.1:28001'},
    {_id: 1, host: '127.0.0.1:28002'},
    {_id: 2, host: '127.0.0.1:28003'},
  ],
});
{% endhighlight %}

## 2. 将replica set重启为shard
首先将secondary节点启动为shard，虽然可以通过在启动命令中增加参数`--shardsvr`来达到这个目的，但我觉得通过配置文件来启动是个更好的习惯，这样可以更好地跟踪变化。

修改配置文件，增加以下内容：
{% highlight sh %}
sharding:
  clusterRole: shardsvr
{% endhighlight %}

两个secondary节点都启动完毕之后，在primary节点上执行降级命令，将primary节点降为secondary节点：
{% highlight sh %}
rs.stepDown();
{% endhighlight %}
然后以同样的方式重启该节点。

## 3. 启动config server复制集
{% highlight sh %}
storage:
  dbPath: /data/configdb/mongo${1}
  journal:
    enabled: true
  engine: wiredTiger

systemLog:
  destination: file
  path: /data/log/mongodConfigServer${1}.log
  logAppend: true

net:
  port: 2900${1}
  bindIp: 127.0.0.1

processManagement:
  fork: true
  pidFilePath: /data/tmp/mongodConfigServer${1}.pid

replication:
  replSetName: configServerReplSet

sharding:
  clusterRole: configsvr
{% endhighlight %}
假设我们启动三节点复制集，监听以下端口29001、29002、29003，复制集名称为`configServerReplSet`，启动完成后，需要对复制集进行初始化：
{% highlight sh %}
# 连接任一节点
mongo 127.0.0.1:29001
{% endhighlight %}
{% highlight javascript %}
// 在mongo shell中，执行以下代码：
rs.initiate({
  _id: 'configServerReplSet',
  configsvr: true,
  members: [
    {_id: 0, host: '127.0.0.1:29001'},
    {_id: 1, host: '127.0.0.1:29002'},
    {_id: 2, host: '127.0.0.1:29003'},
  ],
});
{% endhighlight %}

## 4. 启动mongos
{% highlight sh %}
systemLog:
  destination: file
  path: /data/log/mongos.log
  logAppend: true

net:
  port: 30001
  bindIp: 127.0.0.1

processManagement:
  fork: true
  pidFilePath: /data/tmp/mongos.pid

sharding:
  configDB: configServerReplSet/127.0.0.1:29001,127.0.0.1:29002,127.0.0.1:29003
{% endhighlight %}
在30001端口上启动mongos，并且使用之前启动的config server复制集作为configDB。
{% highlight sh %}
mongos --config mongos.conf
{% endhighlight %}

## 5. 将之前的复制集加入到shard集群
使用以下命令连接mongos：
{% highlight sh %}
mongo 127.0.0.1:30001/admin
{% endhighlight %}
加入shard集群：
{% highlight sh %}
sh.addShard("rs0/127.0.0.1:28001,127.0.0.1:28002,127.0.0.1:28003")
{% endhighlight %}

## 6. 根据之前提供的配置文件模板启动第二个复制集
初始化：
{% highlight sh %}
rs.initiate({
  _id: 'rs1',
  members: [
    {_id: 0, host: '127.0.0.1:28004'},
    {_id: 1, host: '127.0.0.1:28005'},
    {_id: 2, host: '127.0.0.1:28006'},
  ],
});
{% endhighlight %}

## 7. 将第二个复制集加入shard
{% highlight sh %}
sh.addShard("rs1/127.0.0.1:28004,127.0.0.1:28005,127.0.0.1:28006")
{% endhighlight %}

## 8. 配置shard集群
主要用到的一些命令：
{% highlight js %}
sh.enableSharding( "test" )

use test;
// shard key必须要有索引
db.testColl.createIndex({_id: 1})
sh.shardCollection( "test.testColl", { "_id" : 1 } )
sh.shardCollection( "test.testColl", { "_id" : "hashed" } )

db.testColl.createIndex({name: 1})
sh.shardCollection( "test.testColl", { "name" : 1 } )
{% endhighlight %}

## 参考链接
* [本文所用到的一些scripts](https://github.com/lutaoact/script/tree/master/mongo){:target="_blank"}
* [Convert a Replica Set to a Sharded Cluster](https://docs.mongodb.com/manual/tutorial/convert-replica-set-to-replicated-shard-cluster/){:target="_blank"}
