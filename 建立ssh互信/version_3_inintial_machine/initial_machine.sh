#!/bin/bash
#系统基本配置



mkdir -p /root/.ssh/
chmod -R 700 /root/.ssh/

# install needed tools
yum install net-tools vim -y


cat > /root/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA22eV81pt8JBrizOnQQo7pI81tGI3gKtLrUrdbShGt90J2G5zJcEq4s0dywhhJ6/rJgidfXRKPct81yxGj7iVFmrD5cu/nj+1nAhFPaCki/dvle/xlSCiM1D9Kr7a9m+2PZP7ccIxKENpohARqgusCK+CZ5ybSrfVsAKxUTBxpc8Yz8fSMurUkYL1zNTQMRBE8tkSH7MWstR7Ng4mm6VVSLVmvuixUo7OPIIktvhLBlsKObAWi3iVgz0u/U6+jtvlJuIzDL4w7483prEJaP5xj/ekfrU3TwUKomT2GfWEOYeJ8uPeKuzWpDOOyVmSxG/fZQq4vSBBpwUeyxqv1dn9gQ== hejindan
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqrXvnGdUlFyGdCwSRh7/5rPCzryhRAK8HgxG9nv65d/88rR2SB1vgo/3Ey+2gXrP96OdNgRUZSmdMEr7iSG1yQ4kjzLGjyLq9MmEXpQ+EP1CwWSQvKDWo5N6HdP0QlUrnFqRXI+6lf/sRlESseWF8//iAIDKc85MMzeK9xpQnEXp/eXmAFNAxgwT8vdYavBNIG6d8x0otsGu6tYwVVzqu4vz3QKWTjBQw2efoCZbetugwVVjJbpyC4UzZsU1K7Hdk0OScZhbYuFjtkG+g/TRwJGAws5lVOJm5xuCAEL3SDb2s5CF0I9ehQiI9HXPk5cpo6UXuq9mQLn+SeYRqNy6N fanchao
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDO1Qh6PB3heGLOAwqgZYU+4dNjIxgnkpGhsGbcs/Q7Zpmf1gZFmL/8TfOjBTmsSpsewo6F5hsf/2xFqsY1FFlgloiX79B6WWue3aaHIBOPCGYZJJPOBBNbiMTopGLc/F3NNRlbATjhU803/85opBSCs31S8bizPpWSoS1y/3j6w80Qg48Q5y6JcgtjfGepg7s3ZfBpWrvyaqpDjDo6mJxvdNJqF0loeemkq3C0IN3T8ZIlQ+VQqkAVyUxYNWDIgXfdTQqJ7VdJJBb/1oi4K+Qhm/YXtA7OLkQcd3G3+g0kYnui/yk0JBQSTrD0Ax9kcSXq4MSPktzk5gDoQ4rMcPxB xiaozhong
EOF
chmod -R 700 /root/.ssh/

# 配置sshd的log参数
/bin/cp  /etc/ssh/sshd_config   /etc/ssh/sshd_config.bak.`date +"%Y-%m-%d-%H-%m-%S"`
sed -i 's/#LogLevel INFO/LogLevel VERBOSE/g'  /etc/ssh/sshd_config
#sed -i "s#PasswordAuthentication yes#PasswordAuthentication no#g"  /etc/ssh/sshd_config
sed -i "s@#UseDNS yes@UseDNS no@" /etc/ssh/sshd_config
sed -i '/LogLevel/c\\LogLevel DEBUG'  /etc/ssh/sshd_config
systemctl reload sshd

## 设置selinux
setenforce 0
sed -i -re '/^\s*SELINUX=/s/^/#/' -e '$i\\SELINUX=disabled'  /etc/selinux/config

systemctl stop firewalld
systemctl disable firewalld 
## 判断IP是否私有地址
## $1  IP地址
## 返回: 0 是私有IP, 
##       1 非私有IP, 
##       2 输入有误
is_local_ip (){
        local IP=$1
        echo $IP | egrep -q '^\s*[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\s*$' || return 2
	test $IP = '127.0.0.1' && return 0
        #RANGES='10.0.0.0:10.255.255.255 172.16.0.0:172.31.255.255 192.168.0.0:192.168.255.255'
        ## 私有地址范围转为10进制整数后的值
        RANGES='167772160:184549375  2886729728:2887778303  3232235520:3232301055'
        ## xx点位 256^3   256^2 256 1 
        STEP=(xx 16777216 65536 256 1)
 
        ## 转换IP为10进制整数
        ip2int(){
                local S_IP=$1
                local D_IP=0
                for i in {1..4};do
                        T=`echo $S_IP | cut -d'.' -f$i`
                        [ x$T = x0 -o "x$T" = "x"  ] && continue
                        D_IP=`expr $T \* ${STEP["$i"]} + $D_IP`
                done
                echo $D_IP
        }
 
        for RANGE in $RANGES; do
                RANGE_S=${RANGE%:*}
                RANGE_E=${RANGE#*:}
                INT_IP=`ip2int $IP`
                if [ $INT_IP -ge $RANGE_S -a $INT_IP -le $RANGE_E  ] ;then
                        return 0
                fi
        done
        return 1
}

for IP in $(ifconfig | egrep -o 'addr:([0-9.]+)' | awk  -F: '{print $2}');do
	if ! is_local_ip $IP;then	
		SERVER_IP=$IP
		break
	fi
done
#PASSWD=$(echo '^v……&￥%B52352355h,$fJ'_${SERVER_IP} | md5sum | head -c20)
#echo passwd:$PASSWD
#echo $PASSWD | passwd root --stdin

echo "* soft nofile 102400" >> /etc/security/limits.conf
echo "* hard nofile 102400" >> /etc/security/limits.conf




