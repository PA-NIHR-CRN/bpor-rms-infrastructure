data "external" "check_waf_exists" {
  program = ["/bin/bash", "./modules/scripts/check_waf_exists.sh"]
  query = {
    resource_name   = "wafv2"
    resource_option = "list-web-acls"
    resource_type   = "--scope=CLOUDFRONT --region=us-east-1"
    resource_value  = var.name
    resource_env    = var.env
  }
}

output "waf_enabled" {
  value = data.external.check_waf_exists.result.result
}

output "waf_arn" {
  value = data.external.check_waf_exists.result.arn_exists ? data.external.check_waf_exists.result.arn : module.waf.web_acl_arn
}
