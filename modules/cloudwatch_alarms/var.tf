variable "account" {
  default = "crnccd"
}

variable "system" {
  default = "frf"

}

variable "env" {
  default = "dev"

}

variable "sns_topic" {
}

variable "app" {

}

variable "cluster_instances" {
  default = []

}

variable "api_gateway_list" {
  type    = list(any)
  default = []
}

variable "api_gateway_stage" {
  type    = list(any)
  default = []
}

# -----------------------------------------------------------------------------
# Variables: Cloudwatch Alarms Latency
# -----------------------------------------------------------------------------

variable "resources" {
  description = "Methods that have Cloudwatch alarms enabled"
  type        = map(any)
  default     = {}
}

variable "latency_threshold_p95" {
  description = "The value against which the specified statistic is compared"
  default     = 1000
}

variable "latency_threshold_p99" {
  description = "The value against which the specified statistic is compared"
  default     = 1000
}

variable "latency_evaluationPeriods" {
  description = "The number of periods over which data is compared to the specified threshold"
  default     = 5
}

variable "fourRate_threshold" {
  description = "Percentage of errors that will trigger an alert"
  default     = 0.02
  type        = number
}

variable "fourRate_evaluationPeriods" {
  description = "How many periods are evaluated before the alarm is triggered"
  default     = 5
  type        = number
}

variable "fiveRate_threshold" {
  description = "Percentage of errors that will trigger an alert"
  default     = 0.02
  type        = number
}

variable "fiveRate_evaluationPeriods" {
  description = "How many periods are evaluated before the alarm is triggered"
  default     = 5
  type        = number
}

## ALB

variable "load_balancer_id" {
  type        = string
  description = "ALB ID"
}

variable "target_group_id" {
  type        = string
  description = "Target Group ID"
}


variable "response_time_threshold" {
  type        = string
  default     = "50"
  description = "The average number of milliseconds that requests should complete within."
}

variable "unhealthy_hosts_threshold" {
  type        = string
  default     = "0"
  description = "The number of unhealthy hosts."
}

variable "healthy_hosts_threshold" {
  type        = string
  default     = "0"
  description = "The number of healthy hosts."
}

variable "evaluation_period" {
  type        = string
  default     = "5"
  description = "The evaluation period over which to use when triggering alarms."
}

variable "statistic_period" {
  type        = string
  default     = "60"
  description = "The number of seconds that make each statistic period."
}

# variable "ingest_log_group" {

# }

variable "web_log_group" {

}

variable "sns_topic_service_desk" {

}

# variable "notify_log_group" {

# }

# variable "anomaly_period" {
#   type        = string
#   default     = "600"
#   description = "The number of seconds that make each evaluation period for anomaly detection."
# }

# variable "anomaly_band_width" {
#   type        = string
#   default     = "2"
#   description = "The width of the anomaly band, default 2.  Higher numbers means less sensitive."
# }

# variable "rds_max_connections" {

# }