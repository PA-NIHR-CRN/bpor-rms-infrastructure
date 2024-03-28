variable "env" {
  description = "environment name"
  type        = string

}
variable "system" {
  type = string
}

variable "account" {
  description = "account name"
  type        = string
  default     = "nihrd"

}

variable "ecs_task_role_arn" {
  default = null
}
variable "ecs_execution_task_role_arn" {

}
#------------------------------------------------------------------------------
# CLOUDWATCH EVENT RULE
#------------------------------------------------------------------------------

variable "event_rule_schedule_expression" {
  description = "(Optional) The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes). At least one of event_rule_schedule_expression or event_rule_event_pattern is required. Can only be used on the default event bus."
  default     = null
}

variable "event_rule_event_bus_name" {
  description = "(Optional) The event bus to associate with this rule. If you omit this, the default event bus is used."
  default     = null
}

variable "event_rule_event_pattern" {
  description = "(Optional) The event pattern described a JSON object. At least one of schedule_expression or event_pattern is required."
  default     = null
}

variable "event_rule_description" {
  description = "(Optional) The description of the rule."
  default     = null
}

variable "event_rule_role_arn" {
  description = "(Optional) The Amazon Resource Name (ARN) associated with the role that is used for target invocation."
  default     = null
}

variable "event_rule_is_enabled" {
  description = "(Optional) Whether the rule should be enabled (defaults to true)."
  type        = bool
  default     = true
}

variable "ecs_cluster_arn" {
  description = "The ECS Cluster where the scheduled task will run."
}
