#!/bin/bash
read repoName
if [ -z "$repoName" ]
then
echo 'reponame 0'
exit 1
fi
if [ ! -d /git ]
then
mkdir /git
chown -R git:git /git
fi
if [ -d /git/"$repoName" ]
then
echo 'already exist'
exit 1
fi
mkdir /git/"$repoName"
cd /git/"$repoName"
git --bare init
chown -R git:git /git