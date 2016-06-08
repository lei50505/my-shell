#!/bin/bash
yum update -y
yum install -y python-setuptools
easy_install pip
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