data "aws_iam_policy_document" "aws_dns_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:external-dns"]
    }

    principals {
      type = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
  }
}

resource "aws_iam_role" "aws_dns_controller" {
  assume_role_policy = data.aws_iam_policy_document.aws_dns_controller_assume_role_policy.json
  name = "external-dns"
}

resource "aws_iam_policy" "aws_dns_controller" {
  name = "ExternalDNSAccess"
  policy = jsonencode({
    Statement = [{
      Action = [
        "route53:ChangeResourceRecordSets"
      ]
      Effect = "Allow"
      Resource = "arn:aws:route53:::hostedzone/*"
    }, {
      Action = [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ]
      Effect = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "aws_dns_controller_attach" {
  policy_arn = aws_iam_policy.aws_dns_controller.arn
  role       = aws_iam_role.aws_dns_controller.name
}

output "eks_cluster_dns_arn" {
  value = aws_iam_role.aws_dns_controller.arn
}
