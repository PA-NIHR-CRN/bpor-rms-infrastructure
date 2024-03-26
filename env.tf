variable "env" {
  description = "Env Name"
  type        = string

  validation {
    condition     = var.env == "dev" || var.env == "test" || var.env == "uat" || var.env == "oat" || var.env == "prod"
    error_message = "The Env value must be \"dev\" OR \"oat\" OR \"uat\" OR \"prod\"."
  }
}
