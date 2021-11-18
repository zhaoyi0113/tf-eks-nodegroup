data "aws_iam_policy_document" "alb_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    # condition {
    #   test     = "StringEquals"
    #   variable = "${replace(aws_iam_openid_connect_provider.elk.url, "https://", "")}:sub"
    #   values   = ["system:serviceaccount:kube-system:aws-node"]
    # }

    principals {
      identifiers = [aws_iam_openid_connect_provider.elk.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "alb_service_account" {
  name               = "elk-alb-service-account"
  assume_role_policy = data.aws_iam_policy_document.alb_assume_role_policy.json

  inline_policy {
    name = "elk_alb_sc_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["log:*", "ec2:*", "iam:*", "elasticloadbalancing:*", "cognito-idp:*", "acm:*", "elasticfilesystem:*", "wafv2:*", "waf-regional:*"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

output "elk-alb-service-account-role" {
  value = aws_iam_role.alb_service_account.arn
}
