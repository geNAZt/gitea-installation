#/bin/bash

# Delete postgres to free up the VPC
echo "[postgres] Deleting..."
aws cloudformation delete-stack --stack-name gitea-postgres
aws cloudformation wait stack-delete-complete --stack-name gitea-postgres

# Delete application alarms
echo "[application-alarms] Deleting..."
aws cloudformation delete-stack --stack-name gitea-application-alarms
aws cloudformation wait stack-delete-complete --stack-name gitea-application-alarms

# Delete EKS
eksctl delete cluster --region=eu-central-1 --name=tarent-gittea