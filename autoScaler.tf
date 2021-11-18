data "aws_iam_policy_document" "auto_scaler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [aws_iam_openid_connect_provider.elk.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "auto_scaler_service_account" {
  name               = "elk-auto-scaler-service-account"
  assume_role_policy = data.aws_iam_policy_document.auto_scaler_assume_role_policy.json

  inline_policy {
    name = "elk_alb_sc_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = ["autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeTags",
            "autoscaling:SetDesiredCapacity",
            "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

output "elk-auto-scaller-service-account-role" {
  value = aws_iam_role.auto_scaler_service_account.arn
}

