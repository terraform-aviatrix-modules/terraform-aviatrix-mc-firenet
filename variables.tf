variable "transit_module" {
  description = "Refer to the mc-transit module that built the transit. This module plugs directly into it's output to build firenet on top of it."

  validation {
    condition     = var.transit_module.transit_gateway.enable_transit_firenet == true
    error_message = "Firenet is not enabled on the transit module. Set enable_transit_firenet to true."
  }

  validation {
    condition     = contains(["aws", "azure", "gcp", "oci"], var.transit_module.mc_firenet_details.cloud)
    error_message = "Currently only AWS, Azure, GCP and OCI are supported."
  }
}

variable "instance_size" {
  description = "Instance size for the NGFW's"
  type        = string
  default     = null
}

variable "fw_amount" {
  description = "Integer that determines the amount of NGFW instances to launch"
  type        = number
  default     = 2
  nullable    = false

  validation {
    condition     = var.fw_amount % 2 == 0
    error_message = "Please set fw_amount to an even number. Odd numbers are not supported. If you just want to deploy a single NGFW instance, disabling ha_gw on the transit module will achieve that."
  }
}

variable "hashing_algorithm" {
  description = "Hashing algorithm to load balance traffic across the firewall. Valid values: 2-Tuple, 5-Tuple. Default value: 5-Tuple"
  type        = string
  default     = null
}

variable "attached" {
  description = "Boolean to determine if the spawned firewall instances will be attached on creation"
  type        = bool
  default     = true
  nullable    = false
}

variable "firewall_image" {
  description = "The firewall image to be used to deploy the NGFW's"
  type        = string
}

variable "firewall_image_version" {
  description = "The software version to be used to deploy the NGFW's"
  type        = string
  default     = null
}

variable "iam_role_1" {
  description = "The IAM role for bootstrapping"
  type        = string
  default     = null
}

variable "iam_role_2" {
  description = "The IAM role for bootstrapping"
  type        = string
  default     = ""
  nullable    = false
}

variable "bootstrap_bucket_name_1" {
  description = "The firewall bootstrap bucket name for the odd firewalls (1,3,5 etc)"
  type        = string
  default     = null
}

variable "bootstrap_bucket_name_2" {
  description = "The firewall bootstrap bucket name for the odd firewalls (2,4,6 etc)"
  type        = string
  default     = ""
  nullable    = false
}

variable "inspection_enabled" {
  description = "Set to false to disable inspection"
  type        = bool
  default     = true
  nullable    = false
}

variable "egress_enabled" {
  description = "Set to true to enable egress on FW instances"
  type        = bool
  default     = false
  nullable    = false
}

variable "tags" {
  description = "Map of tags to assign to the firewall instances."
  type        = map(string)
  default     = null
}

variable "egress_static_cidrs" {
  description = "List of egress static CIDRs."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "firewall_image_id" {
  description = "Firewall image ID."
  type        = string
  default     = null
}

variable "user_data_1" {
  description = "User data for bootstrapping Fortigate and Checkpoint firewalls"
  type        = string
  default     = null
}

variable "user_data_2" {
  description = "User data for bootstrapping Fortigate and Checkpoint firewalls"
  type        = string
  default     = ""
  nullable    = false
}

variable "east_west_inspection_excluded_cidrs" {
  description = "Network List Excluded From East-West Inspection."
  type        = list(string)
  default     = null
}

variable "custom_fw_names" {
  description = "If set, the NGFW instances will be deployed with these names. First half of the list for instances in az1, second half for az2."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "username" {
  description = "Username to be configured for NGFW instance"
  type        = string
  default     = null
}

variable "password" {
  description = "Firewall instance password"
  type        = string
  default     = "Aviatrix#1234"
  nullable    = false
}

variable "ssh_public_key" {
  description = "Firewall instance SSH public key"
  type        = string
  default     = null
}

variable "sic_key" {
  description = "SIC key for Checkpoint firewalls"
  type        = string
  default     = null
}

variable "bootstrap_storage_name_1" {
  description = "The firewall bootstrap_storage_name"
  type        = string
  default     = null
}

variable "storage_access_key_1" {
  description = "The storage_access_key to access the storage account"
  type        = string
  default     = null
}

variable "file_share_folder_1" {
  description = "The file_share_folder containing the bootstrap files"
  type        = string
  default     = null
}

variable "bootstrap_storage_name_2" {
  description = "The firewall bootstrap_storage_name"
  type        = string
  default     = ""
  nullable    = false
}

variable "storage_access_key_2" {
  description = "The storage_access_key to access the storage account"
  type        = string
  default     = ""
  nullable    = false
}

variable "file_share_folder_2" {
  description = "The file_share_folder containing the bootstrap files"
  type        = string
  default     = ""
  nullable    = false
}

variable "mgmt_cidr" {
  description = "The CIDR range to be used for the Management VPC for Firenet in GCP"
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = var.mgmt_cidr != "" ? can(cidrnetmask(var.mgmt_cidr)) : true
    error_message = "This does not like a valid CIDR."
  }
}

variable "egress_cidr" {
  description = "The CIDR range to be used for the Egress VPC for Firenet in GCP"
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = var.egress_cidr != "" ? can(cidrnetmask(var.egress_cidr)) : true
    error_message = "This does not like a valid CIDR."
  }
}

variable "associated" {
  description = "Associate firewalls with transit gateway"
  type        = bool
  default     = true
  nullable    = false
}

variable "key_name" {
  description = "Applicable to AWS deployment only. AWS Key Pair name. If not provided a Key Pair will be generated."
  type        = string
  default     = null
}

variable "egress_subnet_1" {
  description = "Subnet for firenet egress interface (odd instances). Only used when mc-transit was built with an existing VNET."
  type        = string
  default     = null
}

variable "egress_subnet_2" {
  description = "Subnet for firenet egress interface (even instances). Only used when mc-transit was built with an existing VNET."
  type        = string
  default     = null
}

variable "mgmt_subnet_1" {
  description = "Subnet for firenet management interface (odd instances). Only used when mc-transit was built with an existing VNET."
  type        = string
  default     = null
}

variable "mgmt_subnet_2" {
  description = "Subnet for firenet management interface (even instances). Only used when mc-transit was built with an existing VNET."
  type        = string
  default     = null
}
