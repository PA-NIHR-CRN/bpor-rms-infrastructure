variable "env" {
  description = "environment name"
  type        = string
}
variable "app" {

}
variable "system" {
  type = string
}

variable "account" {
  description = "account name"
  type        = string
  default     = "nihrd"
}

variable "invoke_lambda_arn" {

}

variable "function_name" {

}
variable "function_alias_name" {

}