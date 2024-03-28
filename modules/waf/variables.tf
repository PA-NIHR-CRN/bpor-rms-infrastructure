variable "name" {}
variable "env" {}
variable "system" {}

variable "waf_create" {
  description = "Change to false to avoid deploying any resources"
  type        = bool
  default     = true
}
variable "log_group" {
  default = []
}
variable "enable_logging" {
  default = false
}
variable "waf_scope" {

}
variable "alb_arn" {

}
variable "waf_ip_set_arn" {

}

variable "app" {

}