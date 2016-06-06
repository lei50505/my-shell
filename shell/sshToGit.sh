#!/bin/bash
read sshKey
if [ -z $sshKey ]
then
echo 'key length 0'
exit 1
fi
echo $sshKey
keyDir=/home/git/.ssh/authorized_keys
if [ ! -f $keyDir ]
then
echo 'mkdir'
mkdir /home/git/.ssh
touch $keyDir
chmod 600 $keyDir
chmod 700 /home/git/.ssh
chown -R git:git /home/git/
fi
grep -x -q "$sshKey" $keyDir
if [ $? -eq 0 ]
then
exit 0
fi
echo $sshKey >> $keyDir
exit 0