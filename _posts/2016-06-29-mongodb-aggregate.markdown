---
layout: post
title:  "mongodb aggregate 那些奇奇怪怪的东西"
date:   2016-06-29 17:35:01 +0800
categories: mongodb aggregate
---

## 操作符

### $redact
通过doc自身存储的内容来限制最后的输出内容。

不多说了，直接上代码，解释一下下面的代码：

第一个流程里面，因为stock_report的顶层是没有reportDate字段，我需要检查的是reports数组里面的reportDate字段是否符合要求，所以用到的是`$$DESCEND`。

第二个流程里面，将检查处理后的reports字段长度，如果是0，表示为空，则直接删除掉这个doc，所以直接`$$PRUNE`，剩下的保留`$$KEEP`。
{% highlight text %}
db.stock_report.aggregate([{
  $redact: {$cond: {
    if: {
      $or: [{
        $not: '$reportDate'
      }, {
        $gte: [
          '$reportDate',
          sixMonthsAgo
        ]
      }]
    },
    then: '$$DESCEND',
    else: '$$PRUNE'
  }}
}, {
  $redact: {$cond: {
    if: {
      $eq: [{$size: '$reports'}, 0]
    },
    then: '$$PRUNE',
    else: '$$KEEP'
  }}
}, {
  $out: 'stock_report6',
}]);
{% endhighlight %}
