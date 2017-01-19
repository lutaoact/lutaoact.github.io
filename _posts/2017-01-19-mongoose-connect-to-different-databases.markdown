---
layout: post
title:  "利用mongoose连接不同的数据库"
date:   2017-01-19 18:21:37 +0800
categories: mongoose connection
---

nodejs + mongodb的使用中，最常用的ORM就是mongoose。常规的数据库连接方式为：
{% highlight js %}
const mongoose = require('mongoose');

mongoose.connect(mongoURI);//mongoURI为连接地址字符串

mongoose.connection.on('error', function () {
  console.error('connection error. make sure server is running.', mongoURI);
  throw new Error('mongoStatusError');
});
mongoose.connection.once('open', function() {
  console.log('open mongodb success', mongoURI);
});

//在创建model的时候，可以直接用mongoose对象使用默认打开的连接
mongoose.model('modelName', schema);
{% endhighlight %}

以上方式适合只使用单一数据库的情况，如果需要跨库操作，则需要打开对新库的连接：
{% highlight js %}
let conn = mongoose.createConnection(mongoURI);
conn.on('error', function () {
  console.error('connection error. make sure server is running.', mongoURI);
  throw new Error('mongoStatusError');
});
conn.once('open', function() {
  console.log('open mongodb success', mongoURI);
});

//在创建model的时候，使用新打开的连接
conn.model('modelName', schema);
{% endhighlight %}
