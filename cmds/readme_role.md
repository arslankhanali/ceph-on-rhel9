# role
export ROLE_NAME=green
export USER_NAME=janedoe
export BUCKET_NAME=test-bucket
export POLICY_NAME=green

radosgw-admin user create --uid=janedoe --access-key=11BS02LGFB6AL6H1ADMW --secret=vzCEkuryfn060dfee4fgQPqFrncKEIkh3ZcdOANY --email=jane@example.com --display-name=Jane

radosgw-admin role create --role-name=$ROLE_NAME \
                          --path=/ \
                          --assume-role-policy-doc='{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":["arn:aws:iam:::user/janedoe"]},"Action":["sts:AssumeRole"]}]}'

radosgw-admin role get --role-name=$ROLE_NAME

radosgw-admin role list --role-name=$ROLE_NAME --path-prefix="/root"

radosgw-admin role-policy get --role-name=$ROLE_NAME --policy-name=$POLICY_NAME

radosgw-admin role-policy list --role-name=green
radosgw-admin role delete --role-name=$ROLE_NAME

s3cmd setpolicy examplepol s3://happybucket