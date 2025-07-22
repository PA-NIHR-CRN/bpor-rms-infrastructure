resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "EMAIL"

  validation_option {
    domain_name       = var.domain_name
    validation_domain = var.validation_email
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
