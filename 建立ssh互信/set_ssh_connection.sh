#!/bin/sh

script=$0
script_dir=$(cd `dirname ${script}` && pwd)
hosts="${script_dir}/hostname/slaves.conf"
ssh_key=$HOME/.ssh/id_rsa.pub
my_ip=$(ip a | egrep -o "10.5.[0-9]+.[0-9]+")

# 关闭防火墙,修改hostname
systemctl stop firewalld.service
systemctl disable firewalld.service
# sh ${script_dir}/hostname/hostname.sh


# install expect
yum install -y expect

if [ ! -s ${ssh_key} ];then
  expect -c "
  spawn ssh-keygen -t rsa
    expect {
      \"*y/n*\" {send \"y\r\"; exp_continue}
      \"*key*\" {send \"\r\"; exp_continue}
      \"*passphrase*\" {send \"\r\"; exp_continue}
      \"*again*\" {send \"\r\";}
    }
  "
fi



# 与其他机器建立ssh互信
for host in $(cat ${hosts})
do
  username=$(echo ${host} | cut -d":" -f1)
  ip=$(echo ${host} | cut -d":" -f2)
  password=$(echo ${host} | cut -d":" -f3)


  echo "ssh-copy-id  ${username}@${ip}"

  expect -c "
    spawn ssh-copy-id ${username}@${ip}
    expect {
      \"*yes/no\" {send \"yes\r\"; exp_continue}
      \"*password*\" {send \"$password\r\"; exp_continue}
      \"*Password*\" {send \"$password\r\";}
    }
  "

  # 在其他机器上执行脚本，相互建立ssh互信，修改hostname
  if [[ $ip != $my_ip ]];then
    scp ${script_dir}/hostname/slaves.conf ${script_dir}/hostname/ssh_connection.sh ${username}@${ip}:~/
    ssh ${username}@${ip} 'sh $HOME/ssh_connection.sh'
    # scp ${script_dir}/hostname/hostname.sh ${script_dir}/hostname/hostlistname.conf ${username}@${ip}:~/
    # ssh  ${username}@${ip} 'sh $HOME/hostname.sh'
    # 关闭防火墙
    ssh ${username}@${ip} 'systemctl stop firewalld.service; systemctl disable firewalld.service'
  fi


done
