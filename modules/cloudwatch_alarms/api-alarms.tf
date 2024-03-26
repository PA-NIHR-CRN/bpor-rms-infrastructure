locals {

  latency95_name = "p95 latency > ${var.latency_threshold_p95}ms over the last ${var.latency_evaluationPeriods} mins"
  latency99_name = "p99 latency > ${var.latency_threshold_p99}ms over the last ${var.latency_evaluationPeriods} mins"

  fourRate_name = "${floor(var.fourRate_threshold * 100)}% 4xx errors over the last ${var.fourRate_evaluationPeriods} mins"
  fiveRate_name = "${floor(var.fiveRate_threshold * 100)}% 5xx errors over the last ${var.fiveRate_evaluationPeriods} mins"
}

# -----------------------------------------------------------------------------
# API Gateway Latency Alarms
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "latency95" {
  count               = length(var.api_gateway_list)
  alarm_name          = "${var.api_gateway_list[count.index]}-95-latency-alarm"
  alarm_description   = "${var.api_gateway_list[count.index]}-95-latency-alarm | ${local.latency95_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.latency_evaluationPeriods
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  unit                = "Milliseconds"
  threshold           = var.latency_threshold_p95
  extended_statistic  = "p95"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiName = var.api_gateway_list[count.index]
    Stage   = var.api_gateway_stage[count.index]
  }

  tags = {
    Name        = "${var.api_gateway_list[count.index]}-95-latency-alarm"
    Environment = var.env
    System      = var.app
  }
}

resource "aws_cloudwatch_metric_alarm" "latency99" {
  count = length(var.api_gateway_list)

  alarm_name          = "${var.api_gateway_list[count.index]}-99-latency-alarm"
  alarm_description   = "${var.api_gateway_list[count.index]}-99-latency-alarm | ${local.latency99_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.latency_evaluationPeriods
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  unit                = "Milliseconds"
  threshold           = var.latency_threshold_p99
  extended_statistic  = "p99"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiName = var.api_gateway_list[count.index]
    Stage   = var.api_gateway_stage[count.index]
  }

  tags = {
    Name        = "${var.api_gateway_list[count.index]}-99-latency-alarm"
    Environment = var.env
    System      = var.app
  }
}

# -----------------------------------------------------------------------------
# API Gateway 4XX Rate error Alarm
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "fourRate" {
  count = length(var.api_gateway_list)

  alarm_name                = "${var.api_gateway_list[count.index]}-4xx-error-alarm"
  alarm_description         = "${var.api_gateway_list[count.index]}-4xx-error-alarm | ${local.fourRate_name}"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = var.fourRate_evaluationPeriods
  threshold                 = var.fourRate_threshold
  insufficient_data_actions = []

  treat_missing_data = "notBreaching"

  metric_query {
    id          = "errorRate"
    label       = "4XX Rate (%)"
    expression  = "error4xx / count"
    return_data = true
  }

  metric_query {
    id    = "count"
    label = "Count"

    metric {
      metric_name = "Count"
      namespace   = "AWS/ApiGateway"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ApiName = var.api_gateway_list[count.index]
        Stage   = var.api_gateway_stage[count.index]
      }
    }

    return_data = false
  }

  metric_query {
    id    = "error4xx"
    label = "4XX Error"

    metric {
      metric_name = "4XXError"
      namespace   = "AWS/ApiGateway"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ApiName = var.api_gateway_list[count.index]
        Stage   = var.api_gateway_stage[count.index]
      }
    }

    return_data = false
  }

  tags = {
    Name        = "${var.api_gateway_list[count.index]}-4xx-error-alarm"
    Environment = var.env
    System      = var.app
  }
}

# -----------------------------------------------------------------------------
# API Gateway 5XX Rate error Alarm
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "fiveRate" {
  count = length(var.api_gateway_list)

  alarm_name                = "${var.api_gateway_list[count.index]}-5xx-error-alarm"
  alarm_description         = "${var.api_gateway_list[count.index]}-5xx-error-alarm | ${local.fiveRate_name}"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = var.fiveRate_evaluationPeriods
  threshold                 = var.fiveRate_threshold
  insufficient_data_actions = []

  treat_missing_data = "notBreaching"

  metric_query {
    id          = "errorRate"
    label       = "5XX Rate (%)"
    expression  = "error5xx / count"
    return_data = true
  }

  metric_query {
    id    = "count"
    label = "Count"

    metric {
      metric_name = "Count"
      namespace   = "AWS/ApiGateway"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ApiName = var.api_gateway_list[count.index]
        Stage   = var.api_gateway_stage[count.index]
      }
    }

    return_data = false
  }

  metric_query {
    id    = "error5xx"
    label = "5XX Error"

    metric {
      metric_name = "5XXError"
      namespace   = "AWS/ApiGateway"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ApiName = var.api_gateway_list[count.index]
        Stage   = var.api_gateway_stage[count.index]
      }
    }

    return_data = false
  }

  tags = {
    Name        = "${var.api_gateway_list[count.index]}-4xx-error-alarm"
    Environment = var.env
    System      = var.app
  }
}