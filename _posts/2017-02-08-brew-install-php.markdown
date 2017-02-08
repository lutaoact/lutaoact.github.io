---
layout: post
title:  "mac中利用brew安装php"
date:   2017-02-08 11:38:53 +0800
categories: homebrew php
---

假设你已经安装好brew了。

* 系统：`MAC OS X Yosemite(10.10.5)`
* php版本：`5.5.27`

mac系统内置的php版本，编译的是openssl 0.9.8zc，大家都知道，旧版openssl有一个重大bug，现在都建议使用1.0.1以后的版本。单独升级openssl是不行的，需要php重新将新版编译进去，brew可以很好地处理这些依赖关系，所以安装方法很容易。

{% highlight sh %}
brew tap homebrew/dupes
brew tap homebrew/versions
brew tap homebrew/homebrew-php

brew install php71
# Once the tap is installed, you can install php53, php54, php55, php56,
# php70, php71, or any formulae you might need
{% endhighlight %}

## 参考链接
* [Homebrew PHP](https://github.com/Homebrew/homebrew-php){:target="_blank"}
