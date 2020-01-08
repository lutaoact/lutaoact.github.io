---
layout: post
title:  "chrome插件-139邮箱助手"
date:   2016-10-26 18:23:04 +0800
categories: chrome extension
---

先吹个牛逼吧，哥也算是发布过chrome插件的人了。

少废话，上代码，[github地址](https://github.com/lutaoact/chrome-extension-139mail)。

当然，吹完牛逼，还得老老实实说话，其实事情是这样的。

以前一直用的插件“139邮箱助手”，后来突然没人不维护了。正好赶上了139邮箱升级，于是这个插件就各种显示错乱，基本属于不可用状态。

最后，自己动手，丰衣足食，经过两天的折腾，居然神奇地搞定了。以下提到的操作都是在mac电脑上完成。

## 插件安装路径
chrome插件安装之后的本地源代码存放路径：
{% highlight text %}
~/Library/'Application Support'/Google/Chrome/Default/Extensions/
{% endhighlight %}
在命令行操作时，如果路径中带有空格，需要使用`\`转义，或者用单引号`'`圈引这段路径。

右键查看插件的详细内容，会打开插件的详情页面，类似下面这样的地址：
{% highlight text %}
https://chrome.google.com/webstore/detail/139邮箱助手/pefpambgoemhbfhilmhanahikdinkfpc
{% endhighlight %}
地址的最后一段路径，就是插件本地安装源代码的目录名称，也就是在这个目录中，我找到了插件的源代码。
{% highlight text %}
~/Library/'Application Support'/Google/Chrome/Default/Extensions/pefpambgoemhbfhilmhanahikdinkfpc
{% endhighlight %}

## 开启开发者模式
直接在地址栏输入以下地址，打开扩展程序页面：
{% highlight text %}
chrome://extensions/
{% endhighlight %}
这个页面的顶部，打勾`开发者模式`：
![打开开发者模式](/assets/developer-mode.jpg)

## 调试源代码
不能直接在安装插件的源代码目录修改代码，这会直接导致插件失效，应该将代码目录复制到其它路径，修改之后，再以开发者模式将程序加载到浏览器中。复制得到的代码目录中，删掉_metadata这个目录，否则重新发布的时候会出错。点击`加载已解压的扩展程序`，然后找到修改之后的源代码的路径，然后就可以安装了。
![检查视图](/assets/check-view.jpg)
`加载来源`可以看到代码路径，`检查视图`就是插件后台加载的网页，直接打开这个页面，就可以利用chrome的调试工具来进行调试了。如果修改了源代码，可以点击`重新加载(⌘R)`来刷新。

每次点击插件跳转的地址都是旧版邮箱的地址，醒目地提醒我`旧版将不再维护，请使用新版`，要不是这个烦人的提示，我估计也就不折腾了。经过反复比对，我发现新版邮箱的地址和旧版相比，只是路径有一点小改动，接下来就是从代码找到相关位置，修改为新的跳转路径，药到病除。

之前用于获取未读邮件列表的API已经不维护了，虽然还能看到API返回的数据，数据结构上基本没变，但具体字段的内容已经乱七八糟了。我花了比较多的时间来找新的API，发现一个问题，之前那个API是为插件专门提供的，所以数据结构刚好能满足插件的需要，而新版邮箱中，并没有这个API。所以我探索出了两个相关的API，将返回数据组合起来，最终实现了我的需求，代码库地址在[这里](https://github.com/lutaoact/chrome-extension-139mail)。

## 发布
以前的应用已经下架了，我觉得肯定有跟我一样，希望继续使用这个插件的人，所以我就把修改后的插件重新发布到了chrome扩展应用中心。

发布过程需要到chrome的[开发者信息中心][developer-center]上传自己的应用，上传的文件需打包成zip格式。如果之前没有发布过应用，需要先付`$5`来进行开发者认证，30多块钱呢。

应用商店貌似还搜不到刚发布的应用，所以把地址附在这里，需要的朋友可以直接安装：
{% highlight text %}
https://chrome.google.com/webstore/detail/139%E9%82%AE%E7%AE%B1%E5%8A%A9%E6%89%8B/pefpambgoemhbfhilmhanahikdinkfpc
{% endhighlight %}

无法连接google的朋友，可以直接下载[139mail.crx][dl-139mail]文件进行安装，下载之后拖动到扩展程序页面(`chrome://extensions/`)即可自动安装。

## 相关链接
* [Chrome插件（Extensions）开发攻略](http://www.cnblogs.com/guogangj/p/3235703.html)
* [Getting Started: Building a Chrome Extension](https://developer.chrome.com/extensions/getstarted)
* [如何发布一款Chrome App](https://segmentfault.com/a/1190000000354014)

[dl-139mail]: http://7xsgzh.com1.z0.glb.clouddn.com/139mail.crx
[developer-center]: https://chrome.google.com/webstore/developer/dashboard/
