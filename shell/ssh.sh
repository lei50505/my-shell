#!/bin/bash

myHome=''
myUser=''
getMyHome(){
if [ $# -ne 1 ]
then
echo 'Get home dir can not by many user name'
return 1
fi
userCount=`cat /etc/passwd | grep -c .*$1.*$1.*`
if [ $userCount -ne 1 ]
then
echo 'Wrong user name'
return 2
fi
myHome=`cat /etc/passwd | grep .*$1.*$1.* | awk -F: '{ print $6 }'`
myUser=$1
return 0
}

addSSHKeyToRoot(){
echo 'Please input a SSH key:'
read mySSHKey
echo $mySSHKey
}


echo '1)Add SSH key'
echo -n 'Please Choose: '
read myFlag
case $myFlag in
1)
addSSHKeyToRoot
;;
2)
addSSHKeyToGit
;;
*)
echo 'Wrong Choice!'
;;
esac
