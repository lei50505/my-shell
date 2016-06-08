#!/bin/bash

changeSSHPort12300(){
if [ ! -f /etc/ssh/sshd_config ]
then
echo 'The SSH config file does not exist.'
return 1
fi
grep -q "^\s*[pP]\{1\}ort\s\{1,\}12300" /etc/ssh/sshd_config
if [ $? -eq 0 ]
then
echo 'The SSH port number is already 12300.'
return 0
fi
sed -i '/^\s*[Pp]\{1\}ort\s\{1,\}/c\Port 12300' /etc/ssh/sshd_config
systemctl restart sshd
echo 'Change the SSH port 12300 success.'
}

addHaseePCPuttyKey(){
sshKey='ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAg8ZRpQBCreQw9vPwz1KDiix+DDwvbI58VC9/x47wTpMu0tyQahSrahq1ku+O+N6UF3fGzNaYdj0GjLXFP6qnserKf0a3l+LT8m5jKd86bDn1fJ1e9iMmCmuJ1NgLtE7yA6FD+EHmY9yGVxPigW1brMLtx8jd6OVsEvKxHABnnmUzYfV1ILs7v+DWuDT2nsQuFz4NN+rvTTqyRiKa4ssZf3OQ5+G0hQvFT+LHy3KguGIFuq9d1Y/vd8OjcDUiwf9sTOMrhXOEY1U1T8w7ZXa/AAcuJ+Nn8V1fCJyC0ZlioF+N0PfxFt+QkRk1jdWONzXaQ8fQ7O1t9/k0uVUq7hVnhQ== rsa-key-20160601'
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
pip install shadowsocks
if [ ! -d /usr/local/my-ss ]
then
mkdir /usr/local/my-ss
fi
cat <<EOF > /usr/local/my-ss/ss.json
{
  "server": "::",
  "server_port": 8388,
  "password": "caolei750107",
  "method": "aes-256-cfb"
}
EOF
cat<<EOF > /usr/lib/systemd/system/my-ss.service
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
}

changeRootPsw90etc(){
echo '90-=op[]'|passwd --stdin root
echo 'Change password for user root success.'
}

installPPTPD(){
type pptpd
if [ $? -eq 0 ]
then
echo 'PPTPD has been already installed.'
return 0
fi
yum install -y epel-release
yum install -y ppp iptables pptpd
sed -i '/^\s*#\s*localip\s*192\.168\.0\.1/c\localip 192.168.0.1' /etc/pptpd.conf
sed -i '/^\s*#\s*remoteip\s*192\.168\.0\.234-238\s*,\s*192\.168\.0\.245/c\remoteip 192.168.0.234-238,192.168.0.245' /etc/pptpd.conf
sed -i '/^#ms-dns\s*10.0.0.1/c\ms-dns 8.8.8.8' /etc/ppp/options.pptpd
sed -i '/^#ms-dns\s*10.0.0.2/c\ms-dns 8.8.4.4' /etc/ppp/options.pptpd
grep -q "\s*pptp\s\{1,\}pptpd\s\{1,\}caolei123\s\{1,\}\*" /etc/ppp/chap-secrets
if [ $? -ne 0 ]
then
echo 'pptp pptpd caolei123 *' >> /etc/ppp/chap-secrets
fi
grep -q "net\.ipv4\.ip_forward=1" /etc/sysctl.conf
if [ $? -ne 0 ]
then
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p
fi
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j SNAT --to-source 144.168.63.86
grep -F -q "iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j SNAT --to-source 144.168.63.86" /etc/rc.d/rc.local
if [ $? -ne 0 ]
then
chmod +x /etc/rc.d/rc.local
echo 'iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j SNAT --to-source 144.168.63.86' >> /etc/rc.d/rc.local
fi
systemctl enable pptpd
systemctl start pptpd
echo 'Install PPTPD success.'
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
*)
echo 'Wrong Choice!'
;;
esac
done