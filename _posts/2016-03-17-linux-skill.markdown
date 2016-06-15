
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

* 获取CPU核数
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
* dos2unix和unix2dos 文件断行格式互转
-n, --newfile INFILE OUTFILE #new file mode, 将转化后的内容写入新文件
-o, --oldfile FILE #old file mode, default mode, 将转化后的内容写入原文件

# BOM(Byte Order Mark)是个很烦人的东西，3个字节，\xEF\xBB\xBF
# dos2unix never writes a BOM in the output file, unless you use option "-m"