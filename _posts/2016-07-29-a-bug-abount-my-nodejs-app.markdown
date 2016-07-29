---
layout: post
title:  "[node] moment模块构造出invalid Date的调查过程"
date:   2016-07-29 17:41:38 +0800
categories: nodejs moment
---

昨天下午，一个同事在开发的时候，遇到了一个很奇怪的问题。

在测试脚本中，利用moment()方法构造时间对象，并把这个对象作为参数传递给需要测试的方法，能得到正确结果。但如果利用node app.js把app启动起来，在controller中调用moment()方法构造时间对象，再传给同样的方法使用时，就会出现invalid Date错误。

本来也有很多办法绕过这个问题，可以无需调查，但我觉得，凡是莫名其妙的问题，必然有不为人知的隐患，所以还是应该调查一下。

调查了挺久，没啥实质的进展，直到，我分别在调用moment()的地方，打出了moment.toString()的内容。内容如下，我发现两个函数的定义居然是不一样的。

{% highlight js %}
//controller中
function (input, format, lang, strict) {
  if (typeof(lang) === "boolean") {
      strict = lang;
      lang = undefined;
  }
  return makeMoment({
      _i : input,
      _f : format,
      _l : lang,
      _strict : strict,
      _isUTC : false
  });
}
{% endhighlight %}

{% highlight js %}
//测试脚本中
function utils_hooks__hooks() {
  return hookCallback.apply(null, arguments);
}
{% endhighlight %}

就在这时，我又发现，在controller中并没有引入moment模块，也就是没有下面这样代码：
{% highlight js %}
const moment = require('moment');
{% endhighlight %}

没有引入，怎么可以使用呢？不应该至少报一个undefined的错误吗？既然没有报错误，那一定是存在一个全局的moment，而且是只在运行app.js的时候，才会被加载。

我知道全局的moment应该是放到global对象上的，所以我就查找global.moment是在哪里设置的，并没有找到。

那我就找这个字符串"input, format, lang, strict"，然后，找到了
{% highlight sh %}
ack --ignore-ack-defaults 'input, format, lang, strict'
# node_modules/file-stream-rotator/node_modules/moment/moment.js
{% endhighlight %}
file-stream-rotator是一个在程序启动时会自动加载的模块，加载的时候会使用自己的moment，并且会将这个moment利用makeGlobal()方法，附加到global对象上。而且这个moment是2.3.1版本的，与我的app使用的版本2.11.1不同，所以构造的moment()对象并不相互兼容。

## 谨以此文来纪念我投入的那一个下午的时间，最后总算弄明白了原因
