variable "foundation" {
  description = "(mandatory) references to the network and management resources such as log analytics and backups"
}

variable "deployment" {
  description = "(mandatory) the definition for this specific resource group deployment"
}

variable "sqldb_backup_template" {
  description = "(optional) used to pass custom ARM template to enable sql db backup on azure vm"
  default     = null
}

variable "standards" {
  description = "(optional) standards for disks (we may need to make this more generic)"
  default     = {}
}

variable "admin_password" {
  description = "(optional) allows password to be passed in using TF_VARS_admin_password environment variable"
  default     = null
}

variable "asr_vault_component" {
  description = "(optional) used to pass ASR vault fabrics and policy details"
  default     = null
}

variable "secrets" {
  description = "a map of secrets"
  default     = {}
  sensitive   = true
}

variable "nsg_default_rules" {
  description = "an array of default rules to add to all defined NSGs"
  default     = []
}

locals {
  # handle optional inputs
  # this approach allows us to keep a clean input JSON and only
  # provide blocks for the specific items we need
  # everything else will default to an empty data set 
  tags = try(var.deployment.tags, {})

  # initialise foundation inputs and add defaults where data is missing
  foundation = merge(
    {
      diagnostics                 = {}
      log_analytics               = {}
      windows_domain              = {}
      recovery_vault              = {}
      application_security_groups = {}
      asr_vault                   = {}
    },
    var.foundation
  )

  # initialise standards by merging with some defaults
  standards = merge(
    {
      data = jsondecode(file("${path.module}/files/standards.json"))
    },
    var.standards
  )
}
