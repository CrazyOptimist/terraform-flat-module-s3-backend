data "aws_caller_identity" "current" {}

locals {
  // We are assuming the role, so, use the current account if no principal ARNs are specified
  principal_arns = var.principal_arns != null ? var.principal_arns : [data.aws_caller_identity.current.arn]
}

resource "aws_iam_role" "iam_role" {
  name = "${local.namespace}-tf-assume-role"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "AWS": ${jsonencode(local.principal_arns)}
        },
        "Effect": "Allow"
      }
    ]
  }
  EOF

  tags = {
    ResourceGroup = local.namespace
  }
}

// Least-privileged policy to attach to the assumed role
data "aws_iam_policy_document" "policy_doc" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.s3_bucket.arn
    ]
  }

  statement {
    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]

    resources = [
      "${aws_s3_bucket.s3_bucket.arn}/*",
    ]
  }

  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [aws_dynamodb_table.dynamodb_table.arn]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name = "${local.namespace}-tf-policy"
  path = "/"
  policy = data.aws_iam_policy_document.policy_doc.json
}