#!/bin/bash
read sshKey
if [ -z $sshKey ]
then
echo 'key length 0'
exit 1
fi
echo $sshKey
keyDir=/root/.ssh/authorized_keys
if [ ! -f $keyDir ]
then
echo 'mkdir'
mkdir /root/.ssh
touch $keyDir
fi
grep -x -q "$sshKey" $keyDir
if [ $? -eq 0 ]
then
exit 0
fi
echo $sshKey >> $keyDir
exit 0