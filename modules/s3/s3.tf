resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = var.s3_bucket_name
    Environment = var.env
    System      = var.system
    Component   = var.app
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_encryption" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "s3_deny_insecure_transport" {
  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

data "aws_iam_policy_document" "s3_cross_account_read_access" {
  statement {
    sid = "AllowCrossAccountReadAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${var.bpor_acc_no}:role/${var.bpor_content_iam_role}"
      ]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

data "aws_iam_policy_document" "combined_s3_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.s3_deny_insecure_transport.json,
    data.aws_iam_policy_document.s3_cross_account_read_access.json
  ]
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = var.s3_bucket_name
  policy = data.aws_iam_policy_document.combined_s3_policy.json
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.s3_bucket.arn
}