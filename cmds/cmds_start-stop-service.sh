
ceph orch ls
ceph orch ps

# #############################################
#  Restart Daemons - RGW
# #############################################
# Restart all rgw services on hosts that have that service
daemons=$(ceph orch ps | grep 'rgw' | awk '{print $1}')

# Restart each service found
for daemon in $daemons; do
    echo "Restarting daemons: $daemon"
    ceph orch daemon restart $daemon
done

# #############################################
#  Restart Daemons - Method 2
# #############################################
# Restart all rgw services on hosts that have that service
cd cephadm-ansible/
ansible -i /etc/ansible/hosts all -m shell -a "systemctl  restart *rgw*" 