resource "aws_eks_cluster" "elk" {
  name                      = var.eks_cluster_name
  role_arn                  = aws_iam_role.elk.arn
  enabled_cluster_log_types = ["api", "audit"]


  vpc_config {
    subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.elk-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.elk-AmazonEKSVPCResourceController,
    aws_cloudwatch_log_group.elk,
  ]
}

resource "aws_iam_role" "elk" {
  # name = "${var.eks_cluster_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "elk-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.elk.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "elk-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.elk.name
}

# eks cluster control plane logging
resource "aws_cloudwatch_log_group" "elk" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name              = "/aws/eks/${var.eks_cluster_name}/cluster"
  retention_in_days = 7
}

# Enabling IAM Roles for Service Accounts

data "tls_certificate" "elk" {
  url = aws_eks_cluster.elk.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "elk" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.elk.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.elk.identity[0].oidc[0].issuer
}
