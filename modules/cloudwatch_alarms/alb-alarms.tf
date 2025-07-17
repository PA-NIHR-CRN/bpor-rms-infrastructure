resource "aws_cloudwatch_metric_alarm" "httpcode_target_5xx_count" {
  count               = var.env == "dev" || var.env == "test" ? 0 : 1
  alarm_name          = "${var.account}-cloudwatch-${var.env}-${var.system}-${var.app}-alb-tg-high5XXCount"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.statistic_period
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Average API 5XX target group error code count is too high"
  alarm_actions       = var.env == "prod" ? [var.sns_topic, var.sns_topic_service_desk] : [var.sns_topic]
  ok_actions          = var.env == "prod" ? [var.sns_topic, var.sns_topic_service_desk] : [var.sns_topic]
  treat_missing_data  = "notBreaching"

  dimensions = {
    "TargetGroup"  = var.target_group_id
    "LoadBalancer" = var.load_balancer_id
  }
  tags = {
    Name        = "${var.account}-cloudwatch-${var.env}-${var.system}-${var.app}-alb-tg-high5XXCount"
    Environment = var.env
    System      = var.system
    Component   = var.app
  }

}

resource "aws_cloudwatch_metric_alarm" "httpcode_lb_5xx_count" {
  count               = var.env == "dev" || var.env == "test" ? 0 : 1
  alarm_name          = "${var.account}-cloudwatch-${var.env}-${var.system}-${var.app}-alb-high5XXCount"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.statistic_period
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Average API 5XX load balancer error code count is too high"
  alarm_actions       = var.env == "prod" ? [var.sns_topic, var.sns_topic_service_desk] : [var.sns_topic]
  ok_actions          = var.env == "prod" ? [var.sns_topic, var.sns_topic_service_desk] : [var.sns_topic]
  treat_missing_data  = "notBreaching"

  dimensions = {
    "LoadBalancer" = var.load_balancer_id
  }
  tags = {
    Name        = "${var.account}-cloudwatch-${var.env}-${var.system}-${var.app}-alb-high5XXCount"
    Environment = var.env
    System      = var.system
    Component   = var.app
  }
}

resource "aws_cloudwatch_metric_alarm" "target_response_time_average" {
  count               = var.env == "dev" || var.env == "test" ? 0 : 1
  alarm_name          = "${var.account}-cloudwatch-${var.env}-${var.system}-${var.app}-alb-tg-highResponseTime"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.response_time_threshold
  alarm_description   = format("Average API response time is greater than %s", var.response_time_threshold)
  alarm_actions       = var.env == "prod" ? [var.sns_topic, var.sns_topic_service_desk] : [var.sns_topic]
  ok_actions          = var.env == "prod" ? [var.sns_topic, var.sns_topic_service_desk] : [var.sns_topic]
  treat_missing_data  = "notBreaching"

  dimensions = {
    "TargetGroup"  = var.target_group_id
    "LoadBalancer" = var.load_balancer_id
  }
  tags = {
    Name        = "${var.account}-cloudwatch-${var.env}-${var.system}-${var.app}-alb-tg-highResponseTime"
    Environment = var.env
    System      = var.system
    Component   = var.app
  }
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  count               = var.env == "dev" || var.env == "test" ? 0 : 1
  alarm_name          = "${var.account}-cloudwatch-${var.env}-${var.system}-${var.app}-alb-tg-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = var.statistic_period
  statistic           = "Minimum"
  threshold           = var.unhealthy_hosts_threshold
  alarm_description   = format("Unhealthy host count is greater than %s", var.unhealthy_hosts_threshold)
  alarm_actions       = var.env == "prod" ? [var.sns_topic, var.sns_topic_service_desk] : [var.sns_topic]
  ok_actions          = var.env == "prod" ? [var.sns_topic, var.sns_topic_service_desk] : [var.sns_topic]

  dimensions = {
    "TargetGroup"  = var.target_group_id
    "LoadBalancer" = var.load_balancer_id
  }
  tags = {
    Name        = "${var.account}-cloudwatch-${var.env}-${var.system}-${var.app}-alb-tg-unhealthy-hosts"
    Environment = var.env
    System      = var.system
    Component   = var.app
  }
}

# resource "aws_cloudwatch_metric_alarm" "healthy_hosts" {
#   count               = var.env == "dev" || var.env == "test" ? 0 : 1
#   alarm_name          = "${var.account}-cloudwatch-${var.env}-${var.system}-${var.app}-alb-tg-healthy-hosts"
#   comparison_operator = "LessThanOrEqualToThreshold"
#   evaluation_periods  = var.evaluation_period
#   metric_name         = "HealthyHostCount"
#   namespace           = "AWS/ApplicationELB"
#   period              = var.statistic_period
#   statistic           = "Minimum"
#   threshold           = var.healthy_hosts_threshold
#   alarm_description   = format("Healthy host count is less than or equal to %s", var.healthy_hosts_threshold)
#   alarm_actions       = var.env == "prod" ? [var.sns_topic, var.sns_topic_service_desk] : [var.sns_topic]
#   ok_actions          = var.env == "prod" ? [var.sns_topic, var.sns_topic_service_desk] : [var.sns_topic]

#   dimensions = {
#     "TargetGroup"  = var.target_group_id
#     "LoadBalancer" = var.load_balancer_id
#   }
#   tags = {
#     Name        = "${var.account}-cloudwatch-${var.env}-${var.system}-${var.app}-alb-tg-healthy-hosts"
#     Environment = var.env
#     System      = var.system
#     Component   = var.app
#   }
# }