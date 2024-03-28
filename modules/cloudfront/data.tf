provider "aws" {
  region = "us-east-1"
}

#data "aws_acm_certificate" "issued" {
#  domain   = "*.${var.domain_name}"
#  statuses = ["ISSUED"]
#}

data "aws_cloudfront_cache_policy" "policy" {
  name = "Managed-CachingOptimized"
  # not compatible with tags
}

data "aws_wafv2_web_acl" "waf" {
  name  = "gscs-aws-waf-policy-${var.account_id}-us-east-1-${var.env}"
  scope = "CLOUDFRONT"
}
