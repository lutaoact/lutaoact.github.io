---
layout: post
title:  "linux笔记整理"
date:   2016-03-17 09:58:27 +0800
categories: linux bash
---

* xargs命令：
{% highlight sh %}
find ~ -name '*.log' -print0 | xargs -0 rm -f #以\0字符分隔文件名列表，处理文件名中含有空格的情况
find /etc -name "*.conf" | xargs ls –l
find . -name *.jpg -type f -print | xargs tar cvzf images.tar.gz #打包所有图片
cat url-list.txt | xargs wget –-continue #下载一个文件中的所有url
{% endhighlight %}

* cd命令使用
{% highlight sh %}
export CDPATH=~:/data
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

shopt -s cdspell #纠正简单的拼写错误
{% endhighlight %}

* grep命令：
{% highlight sh %}
-c #所有匹配的行
-i #忽略大小写
-r #搜索子目录
-l #匹配的文件名
-w #搜索单词，而不是子字符串
-A/-B/-C #显示匹配行的上下文
-e #指定匹配模式 grep -v -e "pattern" -e "pattern"
-o, --only-matching #只显示匹配的字符串
-b, --byte-offset #匹配位置，是对于整个文件而言的，而不是匹配的那一行
-n #显示匹配行号
{% endhighlight %}

* 封锁标准输出或错误
{% highlight sh %}
> /dev/null  #封锁标准输出，只能看到错误
2> /dev/null #封锁错误消息
> /dev/null 2>&1 #错误流重定向，并且都封锁，在cron中比较常见
{% endhighlight %}

* ubuntu修改root用户的初始密码
{% highlight sh %}
sudo passwd
# 提示输入密码，这里是当前用户的密码，校验完成之后
# 提示输入新密码，这里设置的就是root密码，设置成功，可用su切换为root用户
{% endhighlight %}

* 删除当前目录中最大的10个文件或目录
{% highlight sh %}
du -s * | sort -k1 -nr | head -n 10 | awk '{print $2}' | xargs rm -rf
{% endhighlight %}

* 查看linux发行版的详细信息
{% highlight sh %}
lsb_release -a #sudo yum install redhat-lsb-core

# LSB Version:    :core-4.1-amd64:core-4.1-noarch
# Distributor ID: CentOS
# Description:    CentOS Linux release 7.2.1511 (Core)
# Release:        7.2.1511
# Codename:       Core
{% endhighlight %}

* bash中检查变量是否为空，`-n`检查非空为真，`-z`检查空为真
{% highlight sh %}
if [ -n "$VAR" ]; then
  echo "VAR is not empty"
fi

if [ -z "$VAR" ]; then
  echo "VAR is empty"
fi
{% endhighlight %}

* openssl生成文件或字符串的校验和
{% highlight sh %}
openssl sha1/md5 filename #生成指定文件的校验和
echo -n 'xxx' | openssl md5 #生成字符串的校验和
{% endhighlight %}

* watch命令以指定时间间隔自动地运行指定的命令，默认的时间间隔为2秒
{% highlight sh %}
watch sar -P ALL 1 1 #查看所有cpu的使用情况
watch ls -l #查看文件大小的变化
{% endhighlight %}

* rsync同步两个目录
{% highlight sh %}
rsync -rv --exclude=.git \
          --exclude=.gitignore \
          --exclude-from=node-server/.gitignore \
          ~/node-server/ ~/Service/trunk/node-server/
# --exclude      #排除的目录或文件
# --exclude-from #从指定文件中读出排除的目录或文件
# 源路径如果以/结尾，表示同步目录中的内容，如果没有/，则表示同步目录本身
{% endhighlight %}

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
su --login centos -c "$CMD" #以centos用户来执行命令
{% endhighlight %}

* 通过源码安装新版的`gcc`
{% highlight sh %}
#镜像地址 http://www.gnu.org/prep/ftp.html，找一个比较快的
wget http://mirrors.ustc.edu.cn/gnu/gcc/gcc-5.3.0/gcc-5.3.0.tar.bz2
tar xvfj gcc-5.3.0.tar.gz
cd gcc-5.3.0

#下载依赖mpfr gmp mpc isl，这个比自己手动下载要方便很多
./contrib/download_prerequisites

./configure --disable-multilib #--prefix=/usr，默认为/usr/local
#如果提示没有makeinfo，则yum -y install texinfo

make #-j8 8核 可以加-j参数，用来指定cpu核数
#make需要依赖g++，yum install gcc-c++
#make这个过程要进行很久的，半个小时左右，gcc编译安装之后目录从100多M变成了5G

make install

#如果默认安装路径/usr/local，需要转到/usr目录下
sudo update-alternatives --install /usr/bin/gcc gcc /usr/local/bin/gcc 40
{% endhighlight %}

* centos下`g++`安装包名字叫做：`gcc-c++`
{% highlight sh %}
sudo yum -y install gcc-c++
{% endhighlight %}
