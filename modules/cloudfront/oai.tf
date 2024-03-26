resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "${var.env} OAI for cloudfront"
}