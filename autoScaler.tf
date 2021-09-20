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

resource "aws_iam_role" "alb_ServiceAccount" {
  name               = "elk-alb-service-account"
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
