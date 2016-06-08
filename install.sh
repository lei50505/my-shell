#!/bin/bash
changeSSHPort12300(){
sed -i '/^\s*[Pp]\{1\}ort.*$/c\Port 12300' /etc/ssh/sshd_config
systemctl restart sshd
}
addHaseePCPuttyKey(){
mkdir ~/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAg8ZRpQBCreQw9vPwz1KDiix+DDwvbI58VC9/x47wTpMu0tyQahSrahq1ku+O+N6UF3fGzNaYdj0GjLXFP6qnserKf0a3l+LT8m5jKd86bDn1fJ1e9iMmCmuJ1NgLtE7yA6FD+EHmY9yGVxPigW1brMLtx8jd6OVsEvKxHABnnmUzYfV1ILs7v+DWuDT2nsQuFz4NN+rvTTqyRiKa4ssZf3OQ5+G0hQvFT+LHy3KguGIFuq9d1Y/vd8OjcDUiwf9sTOMrhXOEY1U1T8w7ZXa/AAcuJ+Nn8V1fCJyC0ZlioF+N0PfxFt+QkRk1jdWONzXaQ8fQ7O1t9/k0uVUq7hVnhQ== rsa-key-20160601' >> ~/.ssh/authorized_keys
echo '90-=op[]'|passwd --stdin root
}
installShadowsocks(){
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install shadowsocks
mkdir /usr/local/my-ss
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
}
installGit(){
yum install -y git
useradd git
if [ $? -eq 0 ]
then
HOME=/home/git
mkdir $HOME/git-shell-commands
cat >$HOME/git-shell-commands/no-interactive-login <<\EOF
#!/bin/sh
printf '%s\n' "Hi $USER! You've successfully authenticated, but I do not"
printf '%s\n' "provide interactive shell access."
exit 128
EOF
chmod +x $HOME/git-shell-commands/no-interactive-login

grep -q /usr/bin/git-shell /etc/shells
if [ $? -ne 0 ]
then
echo '/usr/bin/git-shell' >> /etc/shells
fi

chsh -s /usr/bin/git-shell git
mkdir /home/git/.ssh
touch /home/git/.ssh/authorized_keys
chown -R git:git $HOME
fi
}
addGitKey(){
if [ -f /home/git/.ssh/authorized_keys ]
then
echo -n 'Please input git key: '
read gitKey
echo $gitKey >> /home/git/.ssh/authorized_keys
fi
}
addGitRepo(){
if [ -f /home/git/.ssh/authorized_keys ]
then
echo -n 'Please input git repo with .git: '
read repoName
mkdir /home/git/"$repoName"
cd /home/git/"$repoName"
git --bare init
chown -R git:git /home/git
fi
}
while true
do
echo '1)changeSSHPort12300'
echo '2)addHaseePCPuttyKey'
echo '3)installShadowsocks'
echo '4)installGit'
echo '5)addGitKey'
echo '6)addGitRepo'
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
*)
echo 'Wrong Choice!'
;;
esac
done