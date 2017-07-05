---
layout: post
title:  "将已有的redis服务迁移到redis集群"
date:   2017-07-05 10:49:56 +0800
categories: redis cluster
---
希望迁移到redis集群的用户可能只有一个master，也可能在用已经存在的分片设置，这种分片设置是他们自己的客户端库或redis代理实现的一些内部算法或者分片算法做的，将所有的key分到了N个节点上。

以上情况都很容易迁移到redis集群，但需要关注的最重要的细节是应用是否用到了多键操作以及如何处理，主要需要讨论以下三种情况：

1. 未用到多键操作、事务、涉及到多键的lua脚本。对key的访问都是独立的，当然也包括使用事务或lua脚本聚合多条命令来访问相同的key
2. 用到多键操作、事务、涉及到多键的lua脚本，但这些键都拥有相同的哈希标签，也就是说同时用到的这些key都有用花括号圈引起来的相同子串，例如：`SUNION {user:1000}.foo {user:1000}.bar`
3. 用到多键操作、事务、涉及到多键的lua脚本，这些key没有明确相同的哈希标签

redis集群目前无法处理第三种情况，需要修改应用逻辑实现不再使用多键操作或只同时使用拥有相同哈希标签的多键。前两种情况都可以处理，并且处理方式是一样的。请评估自己的应用再慎重决定是否适合迁移到redis集群。

## 操作流程
假设我们有一个已经在运行的redis服务，数据集被分配到N个master上，当N=1时，也就是没有使用到分片的情况。

以下是将数据迁移到redis集群的操作步骤（英文说得很清楚，就不翻译了）：

1. Stop your clients. No automatic live-migration to Redis Cluster is currently possible. You may be able to do it orchestrating a live migration in the context of your application / environment.
2. Generate an append only file for all of your N masters using the BGREWRITEAOF command, and waiting for the AOF file to be completely generated.
3. Save your AOF files from aof-1 to aof-N somewhere. At this point you can stop your old instances if you wish (this is useful since in non-virtualized deployments you often need to reuse the same computers).
4. Create a Redis Cluster composed of N masters and zero slaves. You'll add slaves later. Make sure all your nodes are using the append only file for persistence.
5. Stop all the cluster nodes, substitute their append only file with your pre-existing append only files, aof-1 for the first node, aof-2 for the second node, up to aof-N.
6. Restart your Redis Cluster nodes with the new AOF files. They'll complain that there are keys that should not be there according to their configuration.
7. Use redis-trib fix command in order to fix the cluster so that keys will be migrated according to the hash slots each node is authoritative or not.
8. Use redis-trib check at the end to make sure your cluster is ok.
9. Restart your clients modified to use a Redis Cluster aware client library.

还有另一个可选方案是使用`redis-trib import`命令将数据从外部实例导入到redis集群中。命令将运行中的实例的所有key都移动到指定的已经存在的redis集群中，这个过程会将源实例中的key删除。注意：由于redis2.8没有实现迁移连接缓存，所以当其作为源实例时，迁移操作可能会很慢，比较好的方案是，在进行数据迁移操作之前，用redis3.x版本重启源实例。

## 参考链接
* [Redis cluster tutorial](https://redis.io/topics/cluster-tutorial){:target="_blank"}
