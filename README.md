## deploy eks cluster

- terraform apply

## deploy alb controller service accout

- export roleArn=$ServiceAccountRoleArn
- kubectl apply -f spec/serviceAccount.yml