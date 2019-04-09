---
layout: post
title:  "开发环境搭建流程"
date:   2016-01-15 10:33:20 +0800
categories: github-pages bundle jekyll
---

主要流程参考[Github Pages][github-pages]

搭建jekyll的流程参考[Blogging with Jekyll][setup-jekyll-locally]

其它安装注意事项：
{% highlight sh %}
# ruby源总是连不上，使用国内的镜像源
gem sources -l #查看源列表
gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/ #修改源地址

# 安装bundle命令
sudo gem install bundler

# 编辑好Gemfile后，安装其它依赖，最好修改bundle的源，如果有较好的外网，这步可以跳过
bundle config mirror.https://rubygems.org https://gems.ruby-china.com/

bundle install

# 启动
bundle exec jekyll serve

# 更新依赖的各种ruby包
bundle update
{% endhighlight %}

如果MAC开启SIP，则受保护目录/usr/bin无法写入，所以对命令做一些调整
{% highlight sh %}
# 安装到指定目录/usr/local/bin/
gem install -n /usr/local/bin/ bundler
# 调整可执行文件的写入路径到~/bin
bundle install --binstubs=~/bin

{% endhighlight %}

修改ruby的镜像源，可以参考[链接][ruby-mirror]

[github-pages]: https://pages.github.com/
[setup-jekyll-locally]: https://help.github.com/articles/setting-up-your-github-pages-site-locally-with-jekyll/
[ruby-mirror]: https://gems.ruby-china.com/
