variable "foundation" {
  description = "map containing all the foundation variables"
}

variable "secrets" {
  # see https://alm.accenture.com/wiki/display/IACHSTBU/Terraform+Standards
  # sensitive_value = try(var.secrets[regex("secret:(.*)", var.sensitive_value_input)[0]], var.sensitive_value_input)
  description = "map containing secrets in key(name):value(secret) pairs"
  sensitive   = true
  default     = {}
}

variable "nsg_default_rules" {
  description = "default nsg rules"
  default     = []
}