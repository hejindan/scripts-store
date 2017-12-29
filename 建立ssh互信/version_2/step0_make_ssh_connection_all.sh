#!/bin/sh

# set the local host connection to each other
chmod +x make_ssh_connection.sh
./make_ssh_connection.sh


cat nodes.conf | while read line ; do
    host=$(echo $line | awk -F: '{print $2}')
    username=$(echo $line | awk -F: '{print $3}')

    scp make_ssh_connection.sh nodes.conf ${username}@${host}:/tmp

    ssh ${username}@${host} -n 'sh /tmp/make_ssh_connection.sh'

done
