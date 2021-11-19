#!/bin/sh
APP_NAME=monitor
ACCOUNT=${ACCOUNT:-`aws sts get-caller-identity --query Account --output text`}
REGION=${AWS_DEFAULT_REGION:-ap-southeast-2}
BUCKET_NAME="bucket=$APP_NAME-deployment-$REGION-$ACCOUNT"
terraform=${terraform:-terraform}

echo Deploy to $STAGE $ACCOUNT $REGION $BUCKET_NAME

$terraform init -backend-config=$BUCKET_NAME \
        -backend-config="key=tf/$APP_NAME.json" \
        -backend-config="region=$REGION" \
        -migrate-state -force-copy -input=true

$terraform apply -auto-approve
