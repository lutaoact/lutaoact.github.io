---
layout: post
title:  "nodejs中stream pipe的错误处理"
date:   2017-01-16 14:10:33 +0800
categories: nodejs stream pipe
---

在pipe的链中，error事件并不会在管道中传递，所以，像这样的代码：
{% highlight js %}
var a = createStream();
a.pipe(b).pipe(c).on('error', function(e){handleError(e)});
{% endhighlight %}
只会监听stream c的error事件，a或b触发的任意error事件都不会向下传递，而是直接被抛出。所以，正确的处理方式是：
{% highlight js %}
var a = createStream();
a.on('error', function(e){handleError(e)})
.pipe(b)
.on('error', function(e){handleError(e)})
.pipe(c)
.on('error', function(e){handleError(e)});
{% endhighlight %}

当一个error事件被触发的时候，并不会显式地触发一个end事件。一个error事件的触发会结束stream。

也可以用domain来处理，此处按下不表，以后有机会再详述。

## 参考链接
* [Error handling with node.js streams](http://stackoverflow.com/questions/21771220/error-handling-with-node-js-streams){:target="_blank"}
* [Should stream.pipe forward errors?](http://grokbase.com/t/gg/nodejs/12bwd4zm4x/should-stream-pipe-forward-errors){:target="_blank"}
