#!/bin/bash
function gatfile {
# 此处定义一个函数，作为一个线程(子进程)
#具体操作
dir=`dirname $0`
cd $dir
url=`pwd`
cd $url

ssh="ssh -p 22 -o StrictHostKeyChecking=no -o GSSAPIAuthentication=no"
scp="scp -r -P 22 -o StrictHostKeyChecking=no -o GSSAPIAuthentication=no"

#这里是需要执行的操作start
#$scp ./install-docker-k8s.sh centos@$2:/home/centos
#$ssh -tt $2 sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
#$ssh -tt $2 sudo sed -i 's/--log-driver=journald/--log-driver=json-file/g' /etc/sysconfig/docker
#$ssh -tt $2 sudo sed -i 's/--selinux-enabled/--selinux-enabled=false/g' /etc/sysconfig/docker
#$ssh -tt $2 sudo systemctl daemon-reload
#$ssh -tt $2 sudo systemctl enable docker
$scp -tt  ./exchangekey.sh root@$2:/tmp
$ssh -tt root@$2 sudo sh /tmp/exchangekey.sh

#这里是需要执行的操作end



[ $? -eq 0 ] && echo -e "\033[1;32m $5 -- $3 -- $5   succeed\033[0m" || { echo -e "gatfile $1 $2 $3 $2 $5 $6   \033[1;31m \033[05m    fail\033[0m"| tee -a ./failure.log ; }
echo -e "\e[33m ===============================================================================  \e[0m"
}

if [ $# -ne 1 ];then
echo "Usage:`basename $0` listname"
echo "ps:make sure the listname existed ,and correct format."
exit 1
fi

#跳转至当前目录
cd `dirname $0`

#这里定义各种参数
thread=30 # 此处定义线程数
faillog="./failure.log" # 此处定义失败列表,注意失败列表会先被删除再重新写入

function trap_exit
{
# 0是什么意思？
 kill -9 0
}

trap 'trap_exit;exit 2' 1 2 3 15

if [ -f $faillog ];then
	rm -f $faillog
fi

tmp_fifofile="./$.fifo"
mkfifo $tmp_fifofile      # 新建一个fifo类型的文件
exec 6<>$tmp_fifofile      # 将fd6指向fifo类型
#为什么要删除？
rm $tmp_fifofile


for ((i=0;i<$thread;i++));do
echo
done >&6 # 事实上就是在fd6中放置了$thread个回车符


filename=$1
exec 5<$filename
while read line <&5
do
excute_line=`echo $line|sed 's/"//g'`
read -u6
# 一个read -u6命令执行一次，就从fd6中减去一个回车符，然后向下执行，
# fd6中没有回车符的时候，就停在这了，从而实现了线程数量控制

{ # 此处子进程开始执行，被放到后台
 $excute_line
 echo >&6 # 当进程结束以后，再向fd6中加上一个回车符，即补上了read -u6减去的那个
} &

done

wait # 等待所有的后台子进程结束
exec 6>&- # 关闭df6

if [ -f $faillog ];then
	echo -e "\033[1;31m \033[05m has failure job\033[0m"
	exit 1
else
	echo -e "\033[1;36m All finish\033[0m"
	exit 0
fi
