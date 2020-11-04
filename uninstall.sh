#/bin/bash

# Delete postgres to free up the VPC
echo "[postgres] Deleting..."
aws cloudformation delete-stack --stack-name gitea-postgres
aws cloudformation wait stack-delete-complete --stack-name gitea-postgres

# Delete EKS
eksctl delete cluster --region=eu-central-1 --name=tarent-gittea