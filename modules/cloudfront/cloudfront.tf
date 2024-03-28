resource "aws_cloudfront_distribution" "cloud_front" {
  origin {
    domain_name = var.lb_dns
    origin_id   = "alb"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # By default, show index.html file
  default_root_object = "index.html"
  enabled             = true

  # aliases = ["${var.dns_name}"]
  # If there is a 404, return index.html with a HTTP 200 Response
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alb"
    default_ttl      = 0
    min_ttl          = 0
    max_ttl          = 0
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.headers_policy.id
  }

  # Distributes content to US and Europe
  price_class = "PriceClass_100"
  # Restricts who is able to access this content
  restrictions {
    geo_restriction {
      # type of restriction, blacklist, whitelist or none
      restriction_type = "none"
    }
  }
  # SSL certificate for the service.
  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 403
    response_code         = 403
    response_page_path    = "/index.html"
  }
  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 404
    response_page_path    = "/index.html"
  }

  web_acl_id = data.aws_wafv2_web_acl.waf.arn

  tags = {
    Name        = var.name
    Environment = var.env
    System      = var.system
  }

}

