#!/bin/sh

script=$0
script_dir=$(cd `dirname ${script}` && pwd)
hosts=${script_dir}/nodes.conf

ssh_key=${HOME}/.ssh/id_rsa.pub
known_hosts=${HOME}/.ssh/known_hosts
# authorized_keys=/tmp/authorized_keys

# install expect
sudo yum install -y expect

# create ssh key on local host
if [ ! -s ${ssh_key} ]; then
    #statements
    expect -c """
    spawn ssh-keygen -t rsa
        expect {
            *.ssh/id_rsa* {send \r; exp_continue}
            *passphrase* {send \r; exp_continue}
            *passphrase* {send \r; exp_continue}

        }
    """
fi

if [ ! -f ${known_hosts} ]; then
    #statements
    touch ${known_hosts}
fi


# write authorized_keys and known_hosts
authorized_keys=`cat ${ssh_key}`

# set connection to hosts
cat ${hosts} | while read line ; do
    host=$(echo $line | awk -F: '{print $2}')
    username=$(echo $line | awk -F: '{print $3}')
    passwd=$(echo $line | awk -F: '{print $4}')

    # make known_hosts
    ssh-keyscan -t ecdsa-sha2-nistp256 ${host} >> ${known_hosts}
    if [ ${username} = "root" ]; then
        #statements
        au_key_client=/${username}/.ssh/authorized_keys
        ssh_dir=/${username}/.ssh
    else
        au_key_client=/home/${username}/.ssh/authorized_keys
        ssh_dir=/home/${username}/.ssh
    fi

    echo "--------------------------------------------------"
    echo "begin to ${username}@${host}"
    echo ${passwd}

    expect_response="
    expect {
        \"*yes/no*\" {send \"yes\n\"; exp_continue;sleep 1;}
        \"*y/n*\" {send \"y\n\"; exp_continue; sleep 1;}
        \"*password*\" {send \"${passwd}\r\"; exp_continue; sleep 1;}
        \"*password*\" {send \"${passwd}\r\";}
    }
    "

    expect -c "
    spawn ssh  ${username}@${host} \"mkdir -p ${ssh_dir} && touch ${au_key_client} && echo ${authorized_keys} >> ${au_key_client} && sudo chmod 600 ${au_key_client}\"
        ${expect_response}
        "

    # sleep 1
done

exit 0
