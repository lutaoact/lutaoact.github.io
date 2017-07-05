---
layout: post
title:  "redis集群指导"
date:   2017-07-04 17:14:37 +0800
categories: redis cluster
---

* 集群总线 cluster bus
* 哈希槽 hash slot
* 哈希标签 hash tag

redis集群的TCP端口：

* 集群中的每个节点都需要打开2个TCP连接。正常的命令端口（比如6379）用来处理客户端连接，将这个端口值增加10000，得到16379，就是数据端口。
* 第二个端口用于集群总线，这是节点之间使用二进制协议的通信通道。集群总线用于故障检测、配置更新、故障迁移授权等等。客服端应该总是连接正常的redis命令端口，永远都不该尝试直接去和集群总线端口通信。但依然要确认防火墙对两个端口都是放行的，否则集群节点之间将无法通信。
* 命令端口和集群总线端口之间的偏移量是固定的10000.

正常工作的redis集群，每个节点的状态：

* 用于和client通信的普通的客服端通信端口（比如6379）应该对所有需要连接到集群的客户端开放，包括集群的其它节点（它们使用客户端通信端口来完成键的迁移）
* 集群总线端口（客户端通信端口 + 10000）必须从其它集群节点是可达的

如果你没有把这两个端口都打开，那集群可能不会正常工作。集群总线使用一种不同的二进制协议进行节点之间的数据交换，这样的方式更适合在使用小带宽和低处理时间的节点之间交换信息。

redis集群使用16384个哈希槽，也就是2的14次方个。槽位计算使用键的CRC16值对16384取模。

redis集群支持对多个键操作，只要执行这条命令设计的所有key都属于相同的哈希槽。用户可以通过哈希标签来强制使多个键都进入相同的哈希槽。

哈希标签是指对于一个key，只有包含在花括号中的子串才会被用来计算hash值，比如this{foo}key和that{foo}key就会被分配到相同的哈希槽中，因为他们拥有相同的hash标签，可以用在处理多个键的单一命令中。

## redis集群配置参数：
{% highlight sh %}
cluster-migration-barrier <count>
一个主节点进行副本迁移后剩余的最小从节点数，低于该值，该主节点的从节点不会进行副本迁移，默认为1
{% endhighlight %}

## 副本迁移

1. 集群总是会从拥有最多副本的主节点迁移副本
2. 为何获得自动副本迁移的好处，你需要为某个主节点多添加一些副本，任意选一个主节点就行
3. 配置参数cluster-migration-barrier控制副本迁移的特性

## 节点升级
从节点升级很容易，直接关机然后用新版本重启即可。主节点升级分以下步骤：

1. 使用"CLUSTER FAILOVER"命令触发一次手动故障迁移
2. 等待主节点变为从节点
3. 使用升级从节点的方法来完成升级
4. 如果需要让升级完的从节点再次变成主节点，那就再出发一次手动故障迁移

## 集群操作相关

### 创建集群配置文件
{% highlight sh %}
#!/usr/local/bin/bash -xv

set -o errexit

cd /data/backup
mkdir -p cluster-test
for i in 7000 7001 7002 7003 7004 7005 7006; do
  cd /data/backup/cluster-test
  mkdir -p "$i"
  cd "$i"
  cat << EOF > "redisCluster$i.conf"
daemonize yes
pidfile /data/tmp/redis$i.pid
port $i
bind 127.0.0.1
logfile /data/log/redis$i.log

cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
EOF
  rm -f nodes.conf
  redis-server "redisCluster$i.conf" #启动服务器
done
{% endhighlight %}

{% highlight sh %}
# redis-trib是一个ruby脚本，可以从redis的github页面获取，在src目录中
wget https://raw.githubusercontent.com/antirez/redis/unstable/src/redis-trib.rb -O /usr/local/bin/redis-trib
{% endhighlight %}

{% highlight sh %}
# 创建集群，6个服务器，3主3备
# --replicas 1 表示为每个master服务器创建一个slave服务器
redis-trib create --replicas 1 127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005
{% endhighlight %}

{% highlight sh %}
# 连接集群，-c参数表示集群模式连接redis
redis-cli -c -p 7000
{% endhighlight %}

{% highlight sh %}
# 查看集群节点信息
redis-cli -p 7000 cluster nodes
# 758dfcab8c11c29d83e975b427e323acf2c42743 127.0.0.1:7001 master - 0 1499157468007 2 connected 5461-10922
# 5230c0e5877df873b13bbd22359a68df9d85a43f 127.0.0.1:7005 slave 7d97001b959b35e8883dc8a9844938e5d3a08aef 0 1499157470025 6 connected
# 7d97001b959b35e8883dc8a9844938e5d3a08aef 127.0.0.1:7002 master - 0 1499157469016 3 connected 10923-16383
# d897eb7def608df0ecf8c63be6ad31cf0827b733 127.0.0.1:7004 slave 758dfcab8c11c29d83e975b427e323acf2c42743 0 1499157468511 5 connected
# d0ab584221c7f833eb7ac376f4cf429c0423ec51 127.0.0.1:7003 slave e00a910f41b8ec427a00115915290388a547f6db 0 1499157469520 4 connected
# e00a910f41b8ec427a00115915290388a547f6db 127.0.0.1:7000 myself,master - 0 0 1 connected 0-5460
{% endhighlight %}

{% highlight sh %}
# 重新分片，reshard参数提供集群中任意服务器的地址即可
# 交互式命令，要求指定目的服务器ID，源服务器ID，然后会打印出哈希槽的移动计划，如果没有问题，直接确认
redis-trib reshard 127.0.0.1:7000
{% endhighlight %}

{% highlight sh %}
# 检查集群是否正常
redis-trib check 127.0.0.1:7000
{% endhighlight %}

{% highlight sh %}
# 添加新节点到集群
redis-trib add-node 127.0.0.1:7006 127.0.0.1:7000
# add-node之后跟着的是新节点的IP地址和端口号，再之后跟着的是集群中任意已存在的节点的IP地址和端口号
# 新加入的节点默认是主节点，但暂时还没有数据，也不包含哈希槽，可以使用前面的reshard来移动哈希槽到该节点

# 可以查看现在的集群节点信息
redis-cli -p 7006 cluster nodes
# 667d9eed0bd1d6c0ad4f25aeffcf065cb74ddec2 127.0.0.1:7006 myself,master - 0 0 0 connected
# 如果需要改为从节点，我们只需要连接上该节点，发送复制指令，下例中设置为7001的从节点
redis-cli -p 7006 cluster replicate 758dfcab8c11c29d83e975b427e323acf2c42743
# 758dfcab8c11c29d83e975b427e323acf2c42743为7001的服务器ID

# 也可以直接将加入的节点设置为从节点
redis-trib add-node --slave --master-id 758dfcab8c11c29d83e975b427e323acf2c42743 127.0.0.1:7006 127.0.0.1:7000
{% endhighlight %}

{% highlight sh %}
# 删除从节点，del-node后的第一个参数是已经在集群中的任意节点，第二个参数为希望删除的节点ID。
redis-trib del-node 127.0.0.1:7000 `<node-id>`
# 也可以用同样的方式删除主节点，但要求主节点必须为空。如果主节点非空，需要先使用reshard将该节点的所有哈希槽移动到其它节点，然后再执行删除操作。
# 删除一个主节点的另一种可选方法是，对该主节点进行一次手动故障迁移，迁移完成后，该主节点会降为从节点，然后执行删除操作。
# 但如果你本来就是希望减少集群中的主节点，那这种方式就没啥用了，你还是需要使用重新分片来迁移哈希槽，然后在删除主节点。
{% endhighlight %}

{% highlight sh %}
# 手动故障迁移
redis支持手动故障迁移，使用"CLUSTER FAILOVER"命令，这个命令必须在你想迁移的主库的其中一个从库上执行。
{% endhighlight %}

## 参考链接
* [Redis cluster tutorial](https://redis.io/topics/cluster-tutorial){:target="_blank"}
