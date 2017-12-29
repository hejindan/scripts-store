## version_1
这个版本使用ssh-copy-id来建立ssh互信，不方便管理。不建议使用。

## version_2

手工建立ssh互信，步骤为：
1. 在本机生成ssh公钥
```
ssh-keygen -t rsa
```
2. 将远程机器的ip加密写入本机的`known_hosts`文件
```
ssh-keyscan -t ecdsa-sha2-nistp256 host_ip >> ~/.ssh/known_hosts
```
3. 将本机的ssh公钥写入远程机器的~/.ssh/authorized_keys文件
```
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
```

**脚本执行**  
1. nodes.conf是需要建立互信机器的列表
2. make_ssh_connection.sh是建立本机与其他机器的信任
3. step0_make_ssh_connection_all.sh引用了make_ssh_connection.sh脚本，将这个脚本传入每个机器并执行，建立所有机器的互相连接。
