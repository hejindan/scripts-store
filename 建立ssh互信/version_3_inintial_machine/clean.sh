cat nodes.conf | while read line ; do
    host=$(echo $line | awk -F: '{print $2}')
    username=$(echo $line | awk -F: '{print $3}')

    echo ${username}@${host}
    ssh ${username}@${host} -n 'sudo rm /root/.ssh/*'

done
