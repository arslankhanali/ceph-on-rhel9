# Great Guide: https://knowledgebase.45drives.com/kb/kb450422-configuring-ceph-object-storage-to-use-multiple-data-pools/

# Install jq
dnf install -y jq

# check all rules
ceph osd crush rule ls

#########################################################
# Define Variable
#########################################################
export ecprofile=ecprofile
export ec_placement=ec_placement
export ecpool=ecpool

export rpool=rpool
export r_placement=r_placement

export app=rgw
export zonegroup=punjab
export zone=lahore # cluster 1

#########################################################
# ERASURE CODING
#########################################################
# check ec profiles
ceph osd erasure-code-profile ls

# Create ec profile
ceph osd erasure-code-profile set $ecprofile \
    k=2 \
    m=1 \
    crush-failure-domain=host

# Create ec pool
ceph osd pool create $ecpool erasure $ecprofile
# Tag pool with rgw application
ceph osd pool application enable $ecpool $app

# Note that for the newly created erasure-coded pool, the MAX AVAIL column shows a higher number of bytes compared with the replicated pool because of the lower raw-to-usable storage ratio.
ceph df

radosgw-admin zonegroup list

# Update Zonegroup
export file_name=zonegroup.json
radosgw-admin zonegroup get > $file_name
jq '.placement_targets += [{"name": "'"$ec_placement"'", "tags": [], "storage_classes": ["STANDARD"]}]' "$file_name" > temp.json && mv temp.json "$file_name" --force
radosgw-admin zonegroup set --infile $file_name

# Update zone
export file_name=zone.json
radosgw-admin zone get > $file_name
jq '.placement_pools += [{"key": "'"$ec_placement"'", "val": {"index_pool": "east.rgw.buckets.index", "storage_classes": {"STANDARD": {"data_pool": "'"$ecpool"'"}}, "data_extra_pool": "east.rgw.buckets.non-ec", "index_type": 0}}]' $file_name > temp.json && mv temp.json $file_name --force
radosgw-admin zone set --infile $file_name
#########################################################
# REPLICATION
#########################################################
# Create pool
ceph osd pool create $rpool 32 32 replicated_rule 3 
# Tag pool with rgw application
ceph osd pool application enable $rpool $app

# Update Zonegroup
radosgw-admin zonegroup list

export file_name=zonegroup.json
radosgw-admin zonegroup get > $file_name
# Add r-placement target
jq '.placement_targets += [{"name": "'"$r_placement"'", "tags": [], "storage_classes": ["STANDARD"]}]' "$file_name" > temp.json && mv temp.json "$file_name" --force
radosgw-admin zonegroup set --infile $file_name

# Update Zone
export file_name=zone.json
radosgw-admin zone get > $file_name
jq '.placement_pools += [{"key": "'"$r_placement"'", "val": {"index_pool": "east.rgw.buckets.index", "storage_classes": {"STANDARD": {"data_pool": "'"$rpool"'"}}, "data_extra_pool": "east.rgw.buckets.non-ec", "index_type": 0}}]' $file_name > temp.json && mv temp.json $file_name --force
radosgw-admin zone set --infile $file_name

#########################################################
# Restart rgw on nodes
#########################################################

# Commit Changes [VERY IMPORTANT When you have multi-site replication setup] 
radosgw-admin period update --commit

daemons=$(ceph orch ps | grep 'rgw' | awk '{print $1}')

# Restart each service found
for daemon in $daemons; do
    echo "Restarting daemons: $daemon"
    ceph orch daemon restart $daemon
done

#########################################################
#  Lets test with SWIFT CLI
# On Cluster 1
# Install swift cli
pip3 install python-swiftclient

# Create a user
radosgw-admin user create --uid='user1' --display-name='First User' --access-key='S3user1' --secret-key='S3user1key'
radosgw-admin subuser create --uid='user1' --subuser='user1:swift' --secret-key='Swiftuser1key' --access=full

# Set variables
export IP="localhost"
export PORT="80"
export SWIFT_AUTH_URL="http://$IP:$PORT/auth/1.0"
export SWIFT_USER="user1:swift"
export SWIFT_KEY="Swiftuser1key"
export R_BUCKET_NAME="replication_bucket"
export EC_BUCKET_NAME="ec_bucket"
export DUMMY_NAME="dummy_file"

# Create 300Mb dumy object
base64 /dev/urandom | head -c 30000000 > $DUMMY_NAME

# Check conenction by listing all buckets to this user
swift -A $SWIFT_AUTH_URL -U $SWIFT_USER -K "$SWIFT_KEY" list

# Create Replication bucket
swift -A $SWIFT_AUTH_URL -U $SWIFT_USER -K "$SWIFT_KEY" post -H "X-Storage-Policy: $r_placement" $R_BUCKET_NAME
# Create EC bucket
swift -A $SWIFT_AUTH_URL -U $SWIFT_USER -K "$SWIFT_KEY" post -H "X-Storage-Policy: $ec_placement" $EC_BUCKET_NAME

# Upload to Rep bucket
swift -A $SWIFT_AUTH_URL -U $SWIFT_USER -K "$SWIFT_KEY" upload $R_BUCKET_NAME $DUMMY_NAME
# Upload to EC bucket
swift -A $SWIFT_AUTH_URL -U $SWIFT_USER -K "$SWIFT_KEY" upload $EC_BUCKET_NAME $DUMMY_NAME

# List objects in buckets
swift -A $SWIFT_AUTH_URL -U $SWIFT_USER -K "$SWIFT_KEY" list $R_BUCKET_NAME
swift -A $SWIFT_AUTH_URL -U $SWIFT_USER -K "$SWIFT_KEY" list $EC_BUCKET_NAME

#########################################################
# Explanation
ceph df

--- RAW STORAGE ---
CLASS    SIZE   AVAIL     USED  RAW USED  %RAW USED
hdd    60 GiB  57 GiB  3.1 GiB   3.1 GiB       5.18
TOTAL  60 GiB  57 GiB  3.1 GiB   3.1 GiB       5.18
 
--- POOLS ---
POOL                     ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
.mgr                      1    1  449 KiB        2  1.3 MiB      0     18 GiB
east.rgw.otp              6   32      0 B        0      0 B      0     18 GiB
east.rgw.log              7   32   51 KiB      665  3.8 MiB      0     18 GiB
.rgw.root                 8   32  8.5 KiB       19  216 KiB      0     18 GiB
default.rgw.log           9   32    182 B        2   24 KiB      0     18 GiB
default.rgw.control      10   32      0 B        8      0 B      0     18 GiB
default.rgw.meta         11   32      0 B        0      0 B      0     18 GiB
east.rgw.control         12   32      0 B        8      0 B      0     18 GiB
east.rgw.meta            13   32   10 KiB       20  211 KiB      0     18 GiB
east.rgw.buckets.index   14   32   11 KiB       77   33 KiB      0     18 GiB
east.rgw.buckets.data    15  256  206 MiB       61  618 MiB   1.12     18 GiB
east.rgw.buckets.non-ec  16   32  4.5 KiB        0   13 KiB      0     18 GiB
ecpool                   17   32   29 MiB        9   43 MiB   0.08     36 GiB
rpool                    21   32   29 MiB        8   86 MiB   0.16     18 GiB

# Explanation
Total available Storage = 57 GiB
Since most pools are replication(3x) = Their usable storage is 57/3 ~ 18Gb

Notice because ecpool is using [2,1] Erasure coding profile it has more available storage
(2/(2+1))*57 ~ 36Gb

#########################################################
# Find out on which OSDs was the objects saved
# Check which OSD is on what host
# Since crush-failure-domain=host, Object should not be on OSDs which are on the same host
ceph osd tree
ceph osd map $rpool $DUMMY_NAME -f json-pretty
ceph osd map $ecpool $DUMMY_NAME -f json-pretty