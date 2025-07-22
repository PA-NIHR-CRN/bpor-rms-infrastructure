resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Id": "SSLPolicy",
  "Statement": [
      {
          "Sid": "AllowSSLRequestsOnly",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:*",
          "Resource": [
              "arn:aws:s3:::${var.bucket_name}",
              "arn:aws:s3:::${var.bucket_name}/*"
          ],
          "Condition": {
              "Bool": {
                  "aws:SecureTransport": "false"
              }
          }
      }
  ]
}
EOT 

  tags = {
    Name        = var.bucket_name
    Environment = var.env
    System      = var.system
    Component   = var.app
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "SSLPolicy",
    "Statement": [
        {
            "Sid": "AllowSSLRequestsOnly",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.bucket_name}",
                "arn:aws:s3:::${var.bucket_name}/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
POLICY
}
