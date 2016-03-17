---
layout: post
title:  "linux命令使用小技巧汇总"
date:   2016-03-17 09:58:27 +0800
categories: linux bash
---

* 命令行中读入变量CMD的两种方法
{% highlight sh %}
read -r -d '' CMD <<'EOF'
echo "In"
whoami
EOF
{% endhighlight %}
{% highlight sh %}
CMD=$(cat << 'EOF'
echo "In"
echo $PATH
whoami
EOF
)
{% endhighlight %}
{% highlight sh %}
echo "$CMD" #必须要有双引号，可以保留换行
{% endhighlight %}
