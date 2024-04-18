# PURGE CEPH CLUSTER
#rm -f /root/.ssh/known_hosts
ceph orch pause

# Get the fsid of the cluster from /etc/ceph/ceph.conf file and run the below command.
# RHEL 9
ceph fsid
ansible -i /etc/ansible/hosts all -m shell -a "cephadm rm-cluster --force --fsid ,de9e18f2-d908-11ee-adfd-2cc260754989" -f 10
ansible -i /etc/ansible/hosts cluster2 -m shell -a "cephadm rm-cluster --force --fsid ,806bbe88-f30c-11ee-a636-525400d1cd5d" -f 10

# RHEL 8

cat > /etc/ansible/hosts  << EOF
[admin]
node5

[cluster1]
node5
node4
node6
EOF

cat /etc/ceph/ceph.conf |grep -i fsid
ansible-playbook -i cluster2 cephadm-purge-cluster.yml -e fsid=0f5f5662-d91e-11ee-b107-2cc260754989 -vvv