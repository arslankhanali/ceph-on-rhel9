# Cannot bind to IP 0.0.0.0 port 9100: [Errno 98] Address already in use
on node4 and node6 kill process that is attached to 9100 port.

su root
sudo lsof -i :9100
sudo kill -9 <>

# Physical disks show up but OSD is not deplpyed

Zap the disks


# node exporter errors

From UI - kill node exporter service
https://node5:8443/#/services

you can recreate it from UI as well


# ERROR: S3 error: 403 (SignatureDoesNotMatch)
use s3cmd_joe.sh instead of s3cmd --configure
# ERROR: S3 error: 403 (InvalidAccessKeyId): The AWS Access Key Id you provided does not exist in our records.
use s3cmd_joe.sh instead of s3cmd --configure