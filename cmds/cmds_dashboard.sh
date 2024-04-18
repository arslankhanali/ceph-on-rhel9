# #############################################
# After restart primary mgr moves to another node
# #############################################
ceph mgr services
curl -k 

ceph orch ps
ceph orch daemon stop mgr.ceph-mon03.kkudmj # This will make the original node primary again
ceph orch daemon restart mgr.ceph-mon03.kkudmj

ceph orch daemon stop mgr.ceph-node02.guysrk 
ceph orch daemon restart mgr.ceph-node02.guysrk 
# #############################################
#  Restart all MGR
# #############################################
daemons=$(ceph orch ps | grep 'mgr' | awk '{print $1}')

# Restart each service found
for daemon in $daemons; do
    echo "Restarting daemons: $daemon"
    ceph orch daemon restart $daemon
done

# #############################################
#  Dashboard RGW
# #############################################
```sh
radosgw-admin user create --uid=dashboard --display-name="Ceph Dashboard" --system --yes-i-really-mean-it
access_key=$(radosgw-admin user info --uid=dashboard | awk '/"access_key"/ {print $2}' | tr -d ',"')
secret_key=$(radosgw-admin user info --uid=dashboard | awk '/"secret_key"/ {print $2}' | tr -d ',"')
ceph dashboard set-rgw-credentials

# #############################################
#  Dashboard reset password
# #############################################
echo "admin@123" > dashboard_password.yml
ceph dashboard ac-user-set-password admin -i dashboard_password.yml