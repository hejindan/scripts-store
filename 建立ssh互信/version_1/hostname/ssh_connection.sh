#!/bin/sh

script=$0
script_dir=$(cd `dirname ${script}` && pwd)
hosts="${script_dir}/slaves.conf"
ssh_key=$HOME/.ssh/id_rsa.pub


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


  echo "ssh-copy-id ${username}@${ip}"

  expect -c "
    spawn ssh-copy-id ${username}@${ip}
    expect {
      \"*yes/no\" {send \"yes\r\"; exp_continue}
      \"*password*\" {send \"$password\r\"; exp_continue}
      \"*Password*\" {send \"$password\r\";}
    }
  "
done
