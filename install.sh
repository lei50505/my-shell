#!/bin/bash

changeSSHPort12300(){
if [ ! -f /etc/ssh/sshd_config ]
then
echo 'The SSH config file does not exist.'
return 1
fi
# grep -q "^\s*[pP]\{1\}ort\s\{1,\}12300" /etc/ssh/sshd_config
grep -q -i -E "^[[:space:]]*port[[:space:]]+12300[[:space:]]*$" /etc/ssh/sshd_config
if [ $? -eq 0 ]
then
echo 'The SSH port number is already 12300.'
return 0
fi
# sed -i '/^\s*[Pp]\{1\}ort\s\{1,\}/c\Port 12300' /etc/ssh/sshd_config
sed -i -r '/^[[:space:]]*[Pp]{1}ort[[:space:]]+/cPort 12300' /etc/ssh/sshd_config
systemctl restart sshd
echo 'Change the SSH port 12300 success.'
}

addHaseePCPuttyKey(){
sshKey='ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAzk9KrXrSYSBD4pIeRX2+KqqcsMvit1z+xxaMsgUSYjp4uXNkmTyQlmxWdQYk/8CihvlkZsG2yk7L5zyQbTcl9xCS237UnMlmuiIRzrFWtL+vYiHc0JEd03ejc9oGoYOmSfmBb+cxR+Wums5kEpxNMnVZFk82HjH1+tidm5JZ1xhtjUYCHlCx0aiJwaf0GXZdVqjvWCtXVuyrUN8b6GlbwwyWm1DgjB7vPkUI5DjKXvl68maPIHqV/o5IuWy9+yzD6MDYilIZq9IQGj5EIS6Jbc65fIm6jdHmLxQzFGD8fAFoxJ10pOhYIl30PMGeGEXWMSUDusP+pBsDjt7CLMQI7Q== rsa-key-20160926'
if [ ! -f ~/.ssh/authorized_keys ]
then
mkdir ~/.ssh
touch ~/.ssh/authorized_keys
fi
grep -q "$sshKey" ~/.ssh/authorized_keys
if [ $? -eq 0 ]
then
echo 'The Hasee PC Putty key has already been added.'
return 0
fi
echo "$sshKey" >> ~/.ssh/authorized_keys
echo 'Add the Hasee PC Putty key success.'
}

installShadowsocks(){
type pip
if [ $? -ne 0 ]
then
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
rm -f get-pip.py
echo 'Install pip success.'
fi
pip show -q shadowsocks
if [ $? -eq 0 ]
then
echo 'The Shadowsocks has already been installed.'
return 0
fi
yum install -y m2crypto
pip install shadowsocks
if [ ! -d /usr/local/my-ss ]
then
mkdir /usr/local/my-ss
fi
cat << EOF > /usr/local/my-ss/ss.json
{
  "server": "::",
  "server_port": 50409,
  "local_address": "127.0.0.1",
  "local_port": 1080,
  "timeout": 20,
  "password": "caolei123",
  "method": "chacha20",
  "fast_open": true,
  "workers": 1
}
EOF
cat << EOF > /usr/lib/systemd/system/my-ss.service
[Unit]
Description=Shadowsocks
After=network.target

[Service]
Type=forking
PIDFile=/usr/local/my-ss/ss.pid
ExecStart=/usr/bin/ssserver -c /usr/local/my-ss/ss.json --pid-file /usr/local/my-ss/ss.pid --log-file /usr/local/my-ss/ss.log -d start
ExecReload=/usr/bin/ssserver -c /usr/local/my-ss/ss.json --pid-file /usr/local/my-ss/ss.pid --log-file /usr/local/my-ss/ss.log -d restart
ExecStop=/usr/bin/ssserver -c /usr/local/my-ss/ss.json --pid-file /usr/local/my-ss/ss.pid --log-file /usr/local/my-ss/ss.log -d stop

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable my-ss
systemctl start my-ss
echo 'Install Shadowsocks success.'
}

installGit(){
type git
if [ $? -eq 0 ]
then
echo 'The Git has already been installed.'
return 0
fi
yum install -y git
useradd git
if [ $? -ne 0 ]
then
userdel -r git
useradd git
fi
mkdir /home/git/git-shell-commands
cat >/home/git/git-shell-commands/no-interactive-login <<\EOF
#!/bin/sh
printf '%s\n' "Hi $USER! You've successfully authenticated, but I do not"
printf '%s\n' "provide interactive shell access."
exit 128
EOF
chmod +x /home/git/git-shell-commands/no-interactive-login

grep -q /usr/bin/git-shell /etc/shells
if [ $? -ne 0 ]
then
echo '/usr/bin/git-shell' >> /etc/shells
fi

chsh -s /usr/bin/git-shell git
mkdir /home/git/.ssh
touch /home/git/.ssh/authorized_keys
chown -R git:git /home/git
echo 'Install Git success.'
}

addGitKey(){
type git
if [ $? -ne 0 ]
then
echo 'Please install git first.'
return 1
fi
if [ ! -f /home/git/.ssh/authorized_keys ]
then
echo 'The git has something wrong, please reinstall it.'
return 2
fi
echo -n 'Please input git key: '
read gitKey
grep -q "$gitKey" /home/git/.ssh/authorized_keys
if [ $? -eq 0 ]
then
echo 'The Git key has already been added.'
return 0
fi
echo "$gitKey" >> /home/git/.ssh/authorized_keys
echo 'Add Git key success.'
}

addGitRepo(){
type git
if [ $? -ne 0 ]
then
echo 'Please install git first.'
return 1
fi
if [ ! -f /home/git/.ssh/authorized_keys ]
then
echo 'The git has something wrong, please reinstall it.'
return 2
fi
echo -n 'Please input git repo name with .git: '
read repoName
if [ -d /home/git/"$repoName" ]
then
echo 'The git repo name exist.'
return 3
fi
mkdir /home/git/"$repoName"
cd /home/git/"$repoName"
git --bare init
chown -R git:git /home/git
echo 'Create git repo success.'
# git remote add d ssh://git@ti19.com:12300/home/git/my-feedback.git
# git remote add c git@git.oschina.net:caolei6/my-paper.git
}

changeRootPsw90etc(){
echo '90-=op[]'|passwd --stdin root
echo 'Change password for user root success.'
}

installPPTPD(){

type pptpd > /dev/null 2>&1
if [ $? -eq 0 ]
then
echo 'PPTPD has been already installed.'
return 0
fi

yum list installed epel-release > /dev/null 2>&1
if [ $? -ne 0 ]
then
yum install -y epel-release
fi

yum list installed ppp > /dev/null 2>&1
if [ $? -ne 0 ]
then
yum install -y ppp
fi

yum list installed iptables > /dev/null 2>&1
if [ $? -ne 0 ]
then
yum install -y iptables
fi

yum list installed net-tools > /dev/null 2>&1
if [ $? -ne 0 ]
then
yum install -y net-tools
fi

yum list installed pptpd > /dev/null 2>&1
if [ $? -ne 0 ]
then
yum install -y pptpd
fi

if [ ! -d /back ]
then
mkdir /back
fi

if [ ! -f /back/pptpd.conf ]
then
cp /etc/pptpd.conf /back/pptpd.conf > /dev/null 2>&1
if [ $? -ne 0 ]
then
echo 'Copy config file not success.'
return 1
fi
fi

if [ ! -f /back/options.pptpd ]
then
cp /etc/ppp/options.pptpd /back/options.pptpd > /dev/null 2>&1
if [ $? -ne 0 ]
then
echo 'Copy config file not success.'
return 1
fi
fi

if [ ! -f /back/chap-secrets ]
then
cp /etc/ppp/chap-secrets /back/chap-secrets > /dev/null 2>&1
if [ $? -ne 0 ]
then
echo 'Copy config file not success.'
return 1
fi
fi

cat <<EOF > /etc/pptpd.conf
option /etc/ppp/options.pptpd
localip 172.16.36.1
remoteip 172.16.36.2-254
EOF

cat <<EOF > /etc/ppp/options.pptpd
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
ms-dns 114.114.114.114
ms-dns 114.114.115.115
proxyarp
lock
nobsdcomp
novj
novjccomp
nologfd
EOF

echo 'pptp pptpd caolei123 *' > /etc/ppp/chap-secrets

grep -q "^\s*net\.ipv4\.ip_forward=1" /etc/sysctl.conf
if [ $? -ne 0 ]
then
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p > /dev/null 2>&1
fi

ip=`ifconfig|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'`

iptables -t nat -A POSTROUTING -s 172.16.36.0/24 -j SNAT --to-source $ip

grep -F -q "iptables -t nat -A POSTROUTING -s 172.16.36.0/24 -j SNAT --to-source $ip" /etc/rc.d/rc.local
if [ $? -ne 0 ]
then
chmod +x /etc/rc.d/rc.local
echo "iptables -t nat -A POSTROUTING -s 172.16.36.0/24 -j SNAT --to-source $ip" >> /etc/rc.d/rc.local
fi

systemctl enable pptpd
systemctl start pptpd
echo 'Install PPTPD success.'
}

installNetSpeeder(){

if [ ! -d /usr/local ]
then
echo '/usr/local not exist!'
return 1
fi

cd /usr/local

if [ -f master.zip ]
then
echo 'Please remove master.zip first!'
return 1
fi

if [ -d net-speeder-master ]
then
echo 'Please remove net-speeder-master folder first!'
return 1
fi

wget https://github.com/snooda/net-speeder/archive/master.zip
if [ $? -ne 0 ]
then
echo 'Download master.zip failed!'
return 2
fi

unzip -o master.zip
if [ $? -ne 0 ]
then
echo 'Unzip master.zip failed!'
return 3
fi

rm -rf master.zip

yum list installed epel-release > /dev/null 2>&1
if [ $? -ne 0 ]
then
yum install -y epel-release
if [ $? -ne 0 ]
then
echo 'Install EPEL failed!'
return 3
fi
fi

yum install -y net-tools gcc-c++ libnet libpcap libnet-devel libpcap-devel

cd net-speeder-master
sh build.sh -DCOOKED

# http://blog.csdn.net/yuesichiu/article/details/51485147

#`echo << EOF  > ~/start-net-speeder.sh
#!/bin/bash
#/usr/bin/nohup /usr/local/net-speeder-master/net_speeder venet0 "ip" > /dev/null 2>&1 &
#EOF

echo 'export NET_SPEEDER_HOME=/usr/local/net-speeder-master' >> /etc/profile.d/my-net-speeder.sh
echo 'export PATH=$NET_SPEEDER_HOME:$PATH' >> /etc/profile.d/my-net-speeder.sh
source /etc/profile.d/my-net-speeder.sh

echo 'start: nohup net_speeder venet0 "ip" > /dev/null 2>&1 &' > run-net-speeder.txt
echo ' stop: killall net_speeder' >> run-net-speeder.txt

echo 'Install Success! Run "nohup net_speeder venet0:0 ip > /dev/null 2>&1 &" to start!'
}

while true
do
echo '1)changeSSHPort12300'
echo '2)addHaseePCPuttyKey'
echo '3)installShadowsocks'
echo '4)installGit'
echo '5)addGitKey'
echo '6)addGitRepo'
echo '7)changeRootPsw90etc'
echo '8)installPPTPD'
echo '9)installNetSpeeder'
echo 'Exit Ctrl+C'
echo -n 'Please Choose: '
read myFlag
case $myFlag in
1)
changeSSHPort12300
;;
2)
addHaseePCPuttyKey
;;
3)
installShadowsocks
;;
4)
installGit
;;
5)
addGitKey
;;
6)
addGitRepo
;;
7)
changeRootPsw90etc
;;
8)
installPPTPD
;;
9)
installNetSpeeder
;;
*)
echo 'Wrong Choice!'
;;
esac
done
