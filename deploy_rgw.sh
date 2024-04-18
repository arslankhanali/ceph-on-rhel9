# Variables CEPH-CLUSTER-1
sudo root
export rgw_realm="pakistan"
export zonegroup_name="punjab"
export zone_name="lahore"
export endpoints="172.16.79.153"
export placement="3 node5 node4 node6"
export replication_user="${zone_name}-ReplicationUser"

# Commands
radosgw-admin realm create --rgw-realm=$rgw_realm --default
radosgw-admin zonegroup create --rgw-zonegroup=$zonegroup_name --endpoints=$endpoints --master --default
radosgw-admin zone create --rgw-zonegroup=$zonegroup_name \
                          --rgw-zone=$zone_name \
                          --endpoints=$endpoints \
                          --master --default 

#radosgw-admin period update --rgw-realm=$rgw_realm --commit

# Create User
radosgw-admin user create --uid=$replication_user --display-name=$replication_user --system > "${replication_user}-keys"

export ACCESS_KEY=$(grep -o '"access_key": "[^"]*' "${replication_user}-keys" | awk -F'"' '{print $4}')
export SECRET_KEY=$(grep -o '"secret_key": "[^"]*' "${replication_user}-keys" | awk -F'"' '{print $4}')
echo $ACCESS_KEY
echo $SECRET_KEY

# Now update Zone keys with user keys we just created
radosgw-admin zone modify --rgw-zone=$zone_name --access-key=$ACCESS_KEY --secret=$SECRET_KEY

# If needed, put Erasure Coded Pools in Zone now. Follow 6-demo-erasurecoding

# Commit the changes
radosgw-admin period update --commit

ceph orch apply rgw $zone_name --realm=$rgw_realm --zone=$zone_name --placement="$placement"

# ceph orch ls
# ceph orch restart rgw.$zone_name

# To test
# Use http instead of https
# curl -k http://localhost:80/
# curl -k http://localhost:8888/

# ceph config set global rgw_dynamic_resharding true


