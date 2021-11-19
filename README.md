## deploy eks cluster

- terraform apply

## deploy alb controller

```bash
- kubectl apply -f spec/serviceAccount.yml # replace Service-Account-Role-Arn with real value which is generated from alb_service_account in alb.tf
- kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.1.1/cert-manager.yaml
- 
- kubectl apply -f spec/v2_2_0_full.yml # replace Your-Cluster-Name with real value
```

## deploy ebs

```
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update

helm upgrade -install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
    --namespace kube-system \
    --set image.repository=602401143452.dkr.ecr.ap-southeast-2.amazonaws.com/eks/aws-ebs-csi-driver \
    --set enableVolumeResizing=true \
    --set enableVolumeSnapshot=true \
    --set controller.serviceAccount.create=false \
    --set controller.serviceAccount.name=aws-load-balancer-controller
```

## deplo auto scaler

```bash
kubectl apply -f spec/autoScaler.yml # update cluster name in --node-group-auto-discovery=
kubectl annotate serviceaccount cluster-autoscaler \
  -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::<ACCOUNT_ID>:role/<AmazonEKSClusterAutoscalerRole>

kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'

kubectl set image deployment cluster-autoscaler \
  -n kube-system \
  cluster-autoscaler=k8s.gcr.io/autoscaling/cluster-autoscaler:v1.20.0
```
