#/bin/bash
echo "This will automatically install a postgres and a gitea in a EKS on your current selected AWS Account"
echo "This can be changed by `export AWS_PROFILE=PROFILE`"

echo " "
echo "This system uses CloudWatch alarms, please provide a alert email address to receive notifications"
read notification_email

cd scripts/
source install-eks.sh
source install-postgres.sh
source install-gitea.sh
cd ..