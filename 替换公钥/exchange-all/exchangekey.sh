#! /bin/bash
pwddir=$(cd `dirname $0`; pwd)

chown root:root /home/authorized_keys
chmod 600 /home/authorized_keys
cp /home/authorized_keys /root/.ssh/authorized_keys
