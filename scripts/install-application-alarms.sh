#!/bin/bash

# Get notification email
EMAIL=$1
STACK_ID=$(aws cloudformation create-stack --stack-name gitea-application-alarms --template-body file://../stacks/application-alarms.yaml --parameters ParameterKey=NotificationList,ParameterValue=${EMAIL} | jq -r .StackId)

echo "[application-alarms] Started deployment of stack: ${STACK_ID}"

# Wait until stack has been fully created
aws cloudformation wait stack-create-complete --stack-name "${STACK_ID}"