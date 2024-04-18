# Sync status
radosgw-admin sync status

#lists
radosgw-admin realm list
radosgw-admin zonegroup list
radosgw-admin zone list
radosgw-admin bucket list
radosgw-admin bucket stats --bucket=ec_bucket

radosgw-admin  user list

# commit
radosgw-admin period update --commit

# #############################################
#  Restart Daemons - RGW
# #############################################
```sh
daemons=$(ceph orch ps | grep 'rgw' | awk '{print $1}')

# Restart each service found
for daemon in $daemons; do
    echo "Restarting daemons: $daemon"
    ceph orch daemon restart $daemon
done

# #############################################