# #############################################
#  Remove east/west RGW
# #############################################
export rgw_realm="pakistan"
export zonegroup_name="punjab"
export zone_name="lahore"

radosgw-admin zonegroup remove --rgw-zonegroup=$zonegroup_name --rgw-zone=$zone_name
radosgw-admin realm delete --rgw-realm=$rgw_realm
radosgw-admin zonegroup delete --rgw-zonegroup=$zonegroup_name
radosgw-admin zone delete --rgw-zone=$zone_name

ceph config set mon mon_allow_pool_delete true

ceph osd pool rm $zone_name.rgw.log $zone_name.rgw.log --yes-i-really-really-mean-it
ceph osd pool rm $zone_name.rgw.meta $zone_name.rgw.meta --yes-i-really-really-mean-it
ceph osd pool rm $zone_name.rgw.control $zone_name.rgw.control --yes-i-really-really-mean-it
ceph osd pool rm $zone_name.rgw.data.root $zone_name.rgw.data.root --yes-i-really-really-mean-it
ceph osd pool rm $zone_name.rgw.gc $zone_name.rgw.gc --yes-i-really-really-mean-it
ceph osd pool rm $zone_name.rgw.data $zone_name.rgw.data --yes-i-really-really-mean-it
ceph osd pool rm $zone_name.rgw.index $zone_name.rgw.index --yes-i-really-really-mean-it
ceph osd pool rm $zone_name.rgw.buckets.index $zone_name.rgw.buckets.index --yes-i-really-really-mean-it

ceph orch rm rgw.$zone_name

# #############################################
#  Remove default RGW
# #############################################
radosgw-admin zonegroup remove --rgw-zonegroup=default --rgw-zone=default
radosgw-admin zone delete --rgw-zone=default
radosgw-admin zonegroup delete --rgw-zonegroup=default

ceph config set mon mon_allow_pool_delete true
ceph osd pool rm .rgw.root .rgw.root --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.log default.rgw.log --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.meta default.rgw.meta --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.control default.rgw.control --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.data.root default.rgw.data.root --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.gc default.rgw.gc --yes-i-really-really-mean-it

# #############################################
#  Remove zone only
# #############################################
export zonegroup_name="punjab"
export zone_name="pindi"
radosgw-admin zonegroup remove --rgw-zonegroup=$zonegroup_name --rgw-zone=$zone_name
radosgw-admin zone delete --rgw-zone=$zone_name
export zone_name="lahore"

# #############################################
#  Erasure
# #############################################
ceph config set mon mon_allow_pool_delete true
ceph osd pool rm ecpool ecpool --yes-i-really-really-mean-it
ceph osd pool rm test-pool test-pool --yes-i-really-really-mean-it

ceph osd erasure-code-profile rm ecprofile
ceph osd erasure-code-profile rm test-pool
