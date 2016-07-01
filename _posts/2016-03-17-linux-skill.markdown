---
layout: post
title:  "linux笔记整理"
date:   2016-03-17 09:58:27 +0800
categories: linux bash
---

* 修改默认的shell
{% highlight sh %}
chpass -s /usr/local/bin/bash
# 使用自己安装的bash，$BASH展示了执行当前bash实例的程序全路径
{% endhighlight %}

* df和du出来的文件和磁盘大小不相同
{% highlight text %}
$ du -sh /
6.9G /

$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1       40G   17G   21G  45% /
tmpfs            16G     0   16G   0% /dev/shm
{% endhighlight %}

如上所示，du出来的结果为6.9G，而df出来的结果为17G。

最常见的原因是文件删除造成的。当一个文件被删除后，在文件系统目录中已经不可见了，所以du就不会再统计它了。然而如果此时还有运行的进程持有这个已经被删除了的文件的句柄，那么这个文件就不会真正在磁盘中被删除，分区超级块中的信息也就不会更改，这样df仍旧会统计这个被删除了的文件。

{% highlight sh %}
# 可以利用lsof查找删除的文件，输出第2列即为pid，找出使用文件的程序，重启
lsof | grep deleted
{% endhighlight %}

* 比较两个文件是否相同
{% highlight sh %}
diff <file1> <file2> #使用最广泛，用于文本文件比较，是基于“行”的比较
cmp  <file1> <file2> #基于“字节”的比较，可用于二进制文件比较，亲测比较速度还是挺快的
# 文件相同时，返回码为0，文件不同时，返回码为1，可用做判断条件

# 其它尝试
# 计算两个文件的sha1值，然后比较是否相同，利用进程代换作为diff命令的输入
diff <(sha1sum <file1> | cut -d" " -f1) <(sha1sum <file2> | cut -d" " -f1)

# 计算校验和，一般在对远程的大文件比较中用得比较广泛，可以避免对大文件的传输
{% endhighlight %}

* 数组使用：
{% highlight sh %}
# 定义数组的两种方式：
# 1. 直接利用括号为数组变量赋值
array=('1  1' 22 33) #两个1之间有两个空格，这个主要是为了以下讲解方便

# 2. 先定义，然后为数组元素赋值
declare -a array

array[0]='1  1'
array[1]=22
array[2]=33

$array #直接使用数组变量名得出的是第一个元素的值
${array[n]} #取第n个元素的值

# 取数组所有元素的值，两种方式有细微区别，类似于shell脚本参数的$*和$@的区别
${array[*]} #会把数组元素拼接成一个字符串，相当于："1  1 22 33 44"
${array[@]} #数组元素保持独立，相当于：'1  1' '22' '33' '44'
# 当把这两个字符串传给echo时，其实没区别，相当于：
echo 1  1 22 33 44 #两个1之间有2个空格，但在shell中，有几个空格，其实没啥差别

# 当需要将数组元素按顺序传给其它程序时，最好使用"${array[@]}"，即用双引号圈引
# 执行以下程序来查看它们的区别
for i in "${array[*]}"; do
  echo "$i"
done

for i in "${array[@]}"; do
  echo "$i"
done

${#array[*]} ${#array[@]} #数组元素个数
${!array[*]} ${!array[@]} #数组中所有有赋值的索引列表

#定义一个关联数组，其它操作类似于普通数组
declare -A assoc_arr #GNU bash才有这个参数，BSD bash貌似没有
{% endhighlight %}

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

* lsof命令(List Open Files)

这条命令主要用于列出各种进程所打开的文件的相关信息。在unix中，一切皆文件。
{% highlight sh %}
lsof /var/log/syslog #提供文件名，列出打开指定文件的进程
lsof +D /var/log/ #列出打开指定目录下的文件的进程
lsof -c ssh -c init #列出以指定名称开始的进程所打开的文件

lsof -u centos  #被指定用户centos打开的文件
lsof -u ^centos #不是被指定用户centos打开的文件

lsof -p <pid> #指定进程打开的文件
{% endhighlight %}

其它的一些参数：
{% highlight sh %}
-t #输出列表中只包含pid字段，并且没有头部行，输出可以通过管道直接传给kill命令
-a #当使用多个参数进行筛选时，默认为OR关系，使用-a可转化为AND关系

# 重复模式，根据指定参数重复执行命令
-r/+r #-r5 +r5 延时5秒重复执行
# +r在找不到打开的文件时，自动结束；-r会持续运行，不管是否能找到打开的文件。
{% endhighlight %}

查找网络连接：（网络连接也是文件）
{% highlight sh %}
lsof -i #列出打开的网络连接
lsof -i -a -p <pid> #列出指定进程使用的网络文件
lsof -i:<port> #列出指定端口上的连接
lsof -i tcp; lsof -i udp #列出所有的tcp和udp连接
# 加上-n参数，可以抑制DNS反向查询，即把ip转化为host的过程，可以使lsof执行更快
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

* 修改文件的字符编码
{% highlight sh %}
# iconv -f [fromcode] -t [tocode] [file] > [newfile]
iconv -f GBK -t UTF-8 file > newfile
{% endhighlight %}

* dos2unix和unix2dos 文件断行格式互转
{% highlight sh %}
-n, --newfile INFILE OUTFILE #new file mode, 将转化后的内容写入新文件
-o, --oldfile FILE #old file mode, default mode, 将转化后的内容写入原文件

# BOM(Byte Order Mark)是个很烦人的东西，3个字节，\xEF\xBB\xBF
# dos2unix never writes a BOM in the output file, unless you use option "-m"
{% endhighlight %}
