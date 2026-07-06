variable "admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
  default     = "azureuser"
}

variable "public_key_path" {
  description = "Path to SSH public key file"
  type        = string
}
