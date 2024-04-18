# s3cmd
```sh
subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
dnf install -y s3cmd
#Run s3cmd_joe.sh and s3cmd_tom.sh
# s3cmd ls
```
# Ceph - How to grant access for multiple S3 users to access a single bucket (https://access.redhat.com/solutions/2954001)
```sh
# Create users
radosgw-admin user create --uid=joe --display-name="Joe" --access-key=joe --secret=admin@123
radosgw-admin user create --uid=tom --display-name="Tom" --access-key=tom --secret=admin@123 --access=full

# Created s3cfg files for both joe and tom
./s3cmd_joe.sh
./s3cmd_tom.sh

# create buckets
s3cmd -c joe mb s3://joe-bucket

# See info
s3cmd -c joe info s3://joe-bucket

# Try ls with tom
s3cmd -c tom ls s3://joe-bucket

# grant all access to bucket but tom will not be able to pull joe's objects
s3cmd -c joe setacl s3://joe-bucket --acl-grant=all:tom 
s3cmd -c joe setacl s3://joe-bucket --acl-grant=read:tom  # read, write, read_acp, write_acp, full_control, all

# To grant all access to each other's objects as well
s3cmd -c joe setacl s3://joe-bucket --acl-grant=all:tom --recursive
s3cmd -c tom setacl s3://joe-bucket --acl-grant=all:joe --recursive

# revoke tom's access
s3cmd -c joe setacl s3://joe-bucket --acl-revoke=all:tom

# Remove all
s3cmd -c joe rb s3://joe-bucket
radosgw-admin user remove --uid=joe
radosgw-admin user remove --uid=tom
```
