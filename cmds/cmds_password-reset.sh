# #############################################
#  Dashboard reset password
# #############################################
echo "admin@123" > dashboard_password.yml
ceph dashboard ac-user-set-password admin -i dashboard_password.yml