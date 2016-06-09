---
layout: post
title:  "linux笔记整理"
date:   2016-03-17 09:58:27 +0800
categories: linux bash
---
* tar命令：
{% highlight sh %}
tar cvf[i] xxxx.tar[.ext] filelist
tar xvf[i] xxxx.tar[.ext]

# [i]是处理不同格式文件时的指示符，与[.ext]的对应关系如下
z => .gz
j => .bz2
J => .xz

# .7z格式的文件，需要安装p7zip包，使用7z命令
7z x xxxx.7z #解压缩
{% endhighlight %}

* scp命令：
{% highlight sh %}
usage: scp [-12346BCEpqrv] [-c cipher] [-F ssh_config] [-i identity_file]
           [-l limit] [-o ssh_option] [-P port] [-S program]
           [[user@]host1:]file1 ... [[user@]host2:]file2
{% endhighlight %}
{% highlight sh %}
-3 #当在两个远程服务器之间复制文件时，使用本地服务器作为中转
-P #指定端口，ssh指定端口参数使用-p，注意区分
-i #指定认证文件，和ssh一样
{% endhighlight %}

* uniq的用法：（只能进行相邻行的比较，所以一般用在sort之后）
{% highlight sh %}
-c #进行计数
-i #忽略大小写
-d #只输出重复过的行
-u #只输出为重复过的行
{% endhighlight %}

* sort的用法：
{% highlight sh %}
-n #按数值排序
-r #反向排序
-k5 #以第5个字段的值排序
-k5r #以第5个字段的值倒排
-t: #以:作为分隔符，默认用tab分隔
-o #支持将排序结果写入原文件
-f #忽略大小写
-b #忽略前导空白
-u #uniq的方式排序
{% endhighlight %}

* xargs命令：
{% highlight sh %}
#以\0字符分隔文件名列表，处理文件名中含有空格的情况
find ~ -name '*.log' -print0 | xargs -0 rm -f

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

* 在脚本中为sudo提供密码
{% highlight sh %}
echo 'password' | sudo -S command
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

* 获取CPU核数
{% highlight sh %}
cat /proc/cpuinfo | grep -c processor
{% endhighlight %}

* 查看系统是32位还是64位的方法
{% highlight text %}
uname -a
file /bin/ls
getconf LONG_BIT
arch
cat /proc/cpuinfo | grep -c 'flags.*lm' #lm指long mode, 支持lm则是64bit
{% endhighlight %}

* date命令：
{% highlight sh %}
date +'%Y-%m-%dT%H:%M:%S%:z' #标准格式'2016-06-05T21:30:35+08:00'
date +'%F %T' #%F为%Y-%m-%d的简写，%T为%H:%M:%S的简写，格式为'2013-10-16 17:10:20'
date +'%F' #只获取日期，格式为'2013-10-16'
date +'%T' #只获取时间，格式为'20:42:13'
date -d '2013-02-22 22:14' +'%s' #获取时间戳，可以指定环境变量时区TZ=Asia/Shanghai
date -d @1361542440 +"%Y-%m-%d %H:%M:%S" #时间戳转为时间格式
date +'%Y%m%d%H%M%S' #20131016171020
date +'%s' #返回时间戳

cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime #修改时区
tzselect #交互模式修改时区

#查看时区
cat /etc/sysconfig/clock #centos
cat /etc/timezone #ubuntu
{% endhighlight %}
