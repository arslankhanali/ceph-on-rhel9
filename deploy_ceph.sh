# cd ~/Codes/ansible-master
ansible-playbook -l node5 playbooks/ssh_copy_privatekey.yaml  
ansible-playbook -l node5 playbooks/copyhostfile.yaml

# On node5 as root 
su root
dnf -y install git ansible-core
ansible-galaxy collection install community.general

cat > /etc/ansible/hosts << EOF
[admin]
node5

[cluster1]
node5
node4
node6
EOF


# on node5 as rc user 
su rc
ssh node4
exit
ssh node6
exit

ansible all -m lineinfile -a "dest=/etc/ssh/sshd_config line='PermitRootLogin yes' state=present" -b # type yes after each change
ansible all -m service -a "name=sshd state=restarted" -b

# As root user
# SSH 
su root
ssh-keygen
ssh-copy-id node5
ssh-copy-id node4
ssh-copy-id node6
# sshpass -f password.txt ssh-copy-id node5
# sshpass -f password.txt ssh-copy-id node4
# sshpass -f password.txt ssh-copy-id node6

# Enable Ceph tools repo
ansible all -m command -a "sudo subscription-manager repos --enable=rhceph-7-tools-for-rhel-9-x86_64-rpms" -b

# clone repo
git clone https://github.com/ceph/cephadm-ansible.git
cd cephadm-ansible
ansible-playbook -i /etc/ansible/hosts -l cluster1 cephadm-preflight.yml

# Deploy ceph
sudo cephadm bootstrap --mon-ip 172.16.79.153 --allow-fqdn-hostname --skip-mon-network
ceph config set mon public_network 172.16.79.0/24

# change admin password
echo "admin@123" > dashboard_password.yml
ceph dashboard ac-user-set-password admin -i dashboard_password.yml

# Add hosts
ssh-copy-id -o StrictHostKeyChecking=no -f -i /etc/ceph/ceph.pub root@node4
ssh-copy-id -o StrictHostKeyChecking=no -f -i /etc/ceph/ceph.pub root@node6

ceph orch host add node4 172.16.79.148
ceph orch host add node6 172.16.79.152

# ceph orch device ls --wide --refresh
ceph orch device zap node4 /dev/nvme0n2 --force
ceph orch daemon add osd node4:/dev/nvme0n2

ceph orch device zap node6 /dev/nvme0n2 --force
ceph orch daemon add osd node6:/dev/nvme0n2
# ceph orch apply osd --all-available-devices
# ceph orch apply osd --all-available-devices --unmanaged=true

# upgrade
ceph orch upgrade start --image quay.io/ceph/ceph:v18.2.2

# ceph --version
# ceph orch upgrade status
# ceph orch upgrade resume

# cephadm shell
# ceph health detail
# ceph -s             
# ceph df 
# ceph osd tree 

# https://localhost:9000/

# ceph config set mon mon_max_pg_per_osd 250 # Default is 250

## Debug service not starting
# systemctl status ceph-e6f4bfe6-fbfa-11ee-a875-0050563abeef@node-exporter.node6.service
# systemctl reboot ceph-e6f4bfe6-fbfa-11ee-a875-0050563abeef@node-exporter.node6.service
# journalctl -u *node-exporter*