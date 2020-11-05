#/bin/bash
# Get the EKS primary VPC, we want to mount the postgres into there
VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:alpha.eksctl.io/cluster-name,Values=tarent-gittea | jq -r .Vpcs[].VpcId)
CIDR=$(aws ec2 describe-vpcs --filters Name=tag:alpha.eksctl.io/cluster-name,Values=tarent-gittea | jq -r .Vpcs[].CidrBlock)
PRIVATE_SUBNETS=$(aws ec2 describe-subnets --filters Name=tag:alpha.eksctl.io/cluster-name,Values=tarent-gittea | jq ".Subnets[] | select(.MapPublicIpOnLaunch == false) | .SubnetId" -r | paste -sd "," -)

echo "[postgres] Detected VPC ID: ${VPC_ID}"
echo "[postgres] Detected CIDR: ${CIDR}"
echo "[postgres] Detected private subnets: ${PRIVATE_SUBNETS}"

# Get notification email
EMAIL=$1
STACK_ID=$(aws cloudformation create-stack --stack-name gitea-postgres --template-body file://../stacks/postgres.yaml --parameters 'ParameterKey=Subnets,ParameterValue="'"${PRIVATE_SUBNETS}"'"' ParameterKey=AllowedCidr,ParameterValue=${CIDR} ParameterKey=DBName,ParameterValue=gitea ParameterKey=VPC,ParameterValue=${VPC_ID} ParameterKey=DBUsername,ParameterValue=gitea ParameterKey=NotificationList,ParameterValue=${EMAIL} | jq -r .StackId)

echo "[postgres] Started deployment of stack: ${STACK_ID}"

# Wait until stack has been fully created
aws cloudformation wait stack-create-complete --stack-name "${STACK_ID}"

export STACK_ID