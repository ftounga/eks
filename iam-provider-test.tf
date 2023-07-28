data "aws_iam_policy_document" "test_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"
    condition {
      test     = "StringEquals"
      values   = [replace(aws_iam_openid_connect_provider.eks.url, "https://", "")]
      variable = "system:serviceaccount:default:aws-test"
    }

    principals {
      type = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
  }
}

resource "aws_iam_role" "test_oidc" {
  assume_role_policy = data.aws_iam_policy_document.test_oidc_assume_role_policy.json
  name = "test-oidc"
}

resource "aws_iam_policy" "test-policy" {
  name = "test-policy"
  policy = jsonencode({
    Statement = [{
      Action = [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
      ]
      Effect = "Allow"
      Resource = "arn:aws:s3:::*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "test_attach" {
  policy_arn = aws_iam_policy.test-policy.arn
  role       = aws_iam_role.test_oidc.name
}

output "tes_policy_arn" {
  value = aws_iam_role.test_oidc.arn
}
