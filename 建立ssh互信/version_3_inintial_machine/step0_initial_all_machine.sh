#!/bin/bash

# set ssh-connections
./make_ssh_connection.sh

# iniatial machines
for line in `cat nodes.conf`; do
        host=$(echo $line | awk -F: '{print $2}')
        username=$(echo $line | awk -F: '{print $3}')
        hostname=$(echo $line | awk -F: '{print $1}')
        ssh ${username}@${host} -n "sudo hostnamectl set-hostname ${hostname}"
        
        scp initial_machine.sh ${username}@${host}:/tmp
        ssh ${username}@${host} -n 'sh /tmp/initial_machine.sh'
	scp nodes.conf ${username}@${host}:/tmp
	scp make_ssh_connection.sh ${username}@${host}:/tmp
	ssh ${username}@${host} -n 'sudo sh /tmp/make_ssh_connection.sh'
    done
