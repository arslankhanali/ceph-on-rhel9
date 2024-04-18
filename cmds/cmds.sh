# #############################################
#  Usual cmds
# #############################################
```sh
# Enable Ceph cli
cephadm shell

ceph health detail
ceph -s             
ceph df 

ceph orch ls
ceph orch host ls
ceph orch device ls

# Crashed daemons
ceph crash ls
ceph crash info 2024-04-172024-04-17T06:37:35.146072Z_6b500b9b-6de5-40bc-bd1a-806ac214311d
ceph crash archive-all

# All Daemons
ceph orch ps
ceph orch daemon start mon.ceph-mon01

ceph quorum_status -f json-pretty

# OSD and pool
ceph osd status 
ceph osd stat -f json-pretty
ceph osd tree 
ceph osd df

ceph osd map <poolname> <objectname> -f json-pretty
ceph osd map default.rgw.buckets.data dummy_file1.txt -f json-pretty

ceph pg dump

ceph osd pool ls
ceph osd pool stats <pool_name>
ceph osd pool get <pool_name> <key>
ceph osd pool get SA-FaultTolerance5-EC-1 crush_rule

rados -p <pool_name> ls
rados -p <pool_name> stat <object_name> 
rados -p <pool_name> rm <object_name> 


