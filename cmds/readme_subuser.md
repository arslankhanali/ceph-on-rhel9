# Subuser read only
```sh
radosgw-admin user create --uid=johndoe --display-name="John Doe" --email=john@example.com --access-key=admin --secret=admin@123
#radosgw-admin subuser create --uid={uid} --subuser={uid} --access=[ read | write | readwrite | full ]
radosgw-admin subuser create --uid=johndoe --subuser=johndoe:swift --access=read --key-type=swift --secret-key admin@123

#Del
radosgw-admin subuser rm --uid=johndoe --subuser=johndoe:swift
```