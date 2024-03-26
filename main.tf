terraform {
  backend "s3" {
    region  = "eu-west-2"
    encrypt = true
  }

}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

## CLOUDWATCH ALARMS

data "aws_sns_topic" "system_alerts" {
  name = "${var.names["${var.env}"]["accountidentifiers"]}-sns-system-alerts"
}

data "aws_sns_topic" "system_alerts_oat" {
  count = var.env == "oat" ? 1 : 0
  name  = "${var.names["${var.env}"]["accountidentifiers"]}-sns-system-alerts-oat"
}

data "aws_sns_topic" "system_alerts_service_desk" {
  count = var.env == "prod" ? 1 : 0
  name  = "${var.names["${var.env}"]["accountidentifiers"]}-sns-system-alerts-service-desk"
}

module "cloudwatch_alarms" {
  source                 = "./modules/cloudwatch_alarms"
  account                = var.names["${var.env}"]["accountidentifiers"]
  env                    = var.env
  system                 = var.names["system"]
  app                    = var.names["${var.env}"]["app"]
  sns_topic              = var.env == "oat" ? data.aws_sns_topic.system_alerts_oat[0].arn : data.aws_sns_topic.system_alerts.arn
  load_balancer_id       = module.ecs.lb_suffix
  target_group_id        = module.ecs.tg_suffix
  web_log_group          = module.ecs.log_group
  sns_topic_service_desk = var.env == "prod" ? data.aws_sns_topic.system_alerts_service_desk[0].arn : ""
}

data "aws_secretsmanager_secret" "terraform_secret" {
  name = "${var.names["${var.env}"]["accountidentifiers"]}-secret-${var.env}-${var.names["system"]}-${var.names["app"]}-terraform"
}

data "aws_secretsmanager_secret_version" "terraform_secret_version" {
  secret_id = data.aws_secretsmanager_secret.terraform_secret.id
}

## ECS FARGATE

module "ecs" {
  source              = "./modules/container-service"
  account             = var.names["${var.env}"]["accountidentifiers"]
  env                 = var.env
  system              = var.names["system"]
  app                 = var.names["app"]
  vpc_id              = var.names["${var.env}"]["vpcid"]
  ecs_subnets         = (var.names["${var.env}"]["ecs_subnet"])
  lb_subnets          = (var.names["${var.env}"]["lb_subnet"])
  container_name      = "${var.names["${var.env}"]["accountidentifiers"]}-ecs-${var.env}-${var.names["system"]}-${var.names["app"]}-container"
  instance_count      = var.names["${var.env}"]["ecs_instance_count"]
  image_url           = "${module.ecr.repository_url}:${var.names["system"]}-${var.names["app"]}-web"
  logs_bucket         = "gscs-aws-logs-s3-${local.account_id}-eu-west-2"
  whitelist_ips       = var.names["${var.env}"]["whitelist_ips"]
  domain_name         = jsondecode(data.aws_secretsmanager_secret_version.terraform_secret_version.secret_string)["domain-name"]
  validation_email    = jsondecode(data.aws_secretsmanager_secret_version.terraform_secret_version.secret_string)["validation-email"]
  ecs_cpu             = var.names["${var.env}"]["ecs_cpu"]
  ecs_memory          = var.names["${var.env}"]["ecs_memory"]
}

module "ecr" {
  source    = "./modules/ecr"
  repo_name = "${var.names["${var.env}"]["accountidentifiers"]}-ecr-${var.env}-${var.names["system"]}-${var.names["app"]}-repository"
  env       = var.env
  system    = var.names["system"]
  app       = var.names["app"]
}

# ## WAF

data "aws_cloudwatch_log_group" "waf_log_group" {
  name = "aws-waf-logs-lg-gscs-${local.account_id}-eu-west-2"
}

data "aws_wafv2_ip_set" "ip_set" {
  name  = "gscs-waf-rate-based-excluded-ips"
  scope = "REGIONAL"
}


module "waf" {
  source         = "./modules/waf"
  name           = "${var.names["${var.env}"]["accountidentifiers"]}-waf-${var.env}-${var.names["system"]}-${var.names["app"]}-acl-eu-west-2"
  env            = var.env
  waf_create     = var.names[var.env]["waf_create"]
  waf_scope      = "REGIONAL"
  alb_arn        = module.ecs.lb_arn
  system         = var.names["system"]
  app            = var.names["app"]
  enable_logging = true
  log_group      = [data.aws_cloudwatch_log_group.waf_log_group.arn]
  waf_ip_set_arn = data.aws_wafv2_ip_set.ip_set.arn
}
