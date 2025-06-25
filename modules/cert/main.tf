provider "aws" {
  region = "eu-west-2"
}

provider "aws" {
  alias  = "alternate_region"
  region = "us-east-1"
}
resource "aws_acm_certificate" "cert" {
  provider          = aws.alternate_region
  domain_name       = var.domain_name
  validation_method = "EMAIL"

  validation_option {
    domain_name       = var.domain_name
    validation_domain = "nihr.ac.uk"
  }
  tags = {
    Environment = var.env
    Name        = var.domain_name
    System      = var.system
    Component   = var.app
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      validation_option
    ]
  }
}

resource "aws_api_gateway_domain_name" "domain" {
  provider        = aws
  domain_name     = aws_acm_certificate.cert.domain_name
  certificate_arn = aws_acm_certificate.cert.arn

  endpoint_configuration {
    types = ["EDGE"]
  }
  security_policy = "TLS_1_2"
  depends_on = [
    aws_acm_certificate.cert
  ]
  tags = {
    Environment = var.env
    Name        = var.domain_name
    System      = var.system
  }
}

resource "aws_api_gateway_base_path_mapping" "path_mapping" {
  provider    = aws
  api_id      = var.api_gateway_id
  domain_name = aws_api_gateway_domain_name.domain.domain_name
  stage_name  = var.api_stage
  depends_on = [
    aws_api_gateway_domain_name.domain
  ]
}

