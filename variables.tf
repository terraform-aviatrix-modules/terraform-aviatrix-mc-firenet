variable "transit_module" {
  description = "Refer to the mc-transit module that built the transit. This module plugs directly into it's output to build firenet on top of it."

  # validation {
  #   condition     = contains(["aws", "azure", "oci", "ali", "gcp"], lower(var.transit_module))
  #   error_message = "Invalid cloud type. Choose AWS, Azure, GCP, ALI or OCI."
  # }  

}

variable "name" {
  description = "Optionally provide a custom name for VPC and Gateway resources."
  type        = string
  default     = ""
}

variable "fw_instance_size" {
  description = "AWS Instance size for the NGFW's"
  type        = string
  default     = "c5.xlarge"
}

variable "fw_amount" {
  description = "Integer that determines the amount of NGFW instances to launch"
  type        = number
  default     = 2
}

variable "attached" {
  description = "Boolean to determine if the spawned firewall instances will be attached on creation"
  type        = bool
  default     = true
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
}

variable "inspection_enabled" {
  description = "Set to false to disable inspection"
  type        = bool
  default     = true
}

variable "egress_enabled" {
  description = "Set to true to enable egress on FW instances"
  type        = bool
  default     = false
}

variable "use_gwlb" {
  description = "Use AWS GWLB for NGFW integration"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Map of tags to assign to the gateway."
  type        = map(string)
  default     = null
}

variable "fw_tags" {
  description = "Map of tags to assign to the firewall or FQDN egress gw's."
  type        = map(string)
  default     = null
}

variable "egress_static_cidrs" {
  description = "List of egress static CIDRs."
  type        = list(string)
  default     = []
}

variable "keep_alive_via_lan_interface_enabled" {
  description = "Enable Keep Alive via Firewall LAN Interface"
  type        = bool
  default     = false
}

variable "firewall_image_id" {
  description = "Firewall image ID."
  type        = string
  default     = null
}

variable "fail_close_enabled" {
  description = "Set to true to enable fail_close"
  type        = bool
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
}

locals {
  transit_gateway         = var.transit_module.transit_gateway
  region                  = var.transit_module.vpc.region
  vpc                     = var.transit_module.vpc
  account                 = var.transit_module.transit_gateway.account_name
  lower_name              = length(var.name) > 0 ? replace(lower(var.name), " ", "-") : replace(lower(local.region), " ", "-")
  is_palo                 = length(regexall("palo", lower(var.firewall_image))) > 0     #Check if fw image is palo. Needs special handling for management_subnet (CP & Fortigate null)
  is_aviatrix             = length(regexall("aviatrix", lower(var.firewall_image))) > 0 #Check if fw image is Aviatrix FQDN Egress
  name                    = local.lower_name
  bootstrap_bucket_name_2 = length(var.bootstrap_bucket_name_2) > 0 ? var.bootstrap_bucket_name_2 : var.bootstrap_bucket_name_1 #If bucket 2 name is not provided, fallback to bucket 1.
  iam_role_2              = length(var.iam_role_2) > 0 ? var.iam_role_2 : var.iam_role_1                                        #If IAM role 2 name is not provided, fallback to IAM role 1.
  user_data_2             = length(var.user_data_2) > 0 ? var.user_data_2 : var.user_data_1                                     #If user data 2 name is not provided, fallback to user data 1.
  use_custom_fw_names     = length(var.custom_fw_names) > 0
  egress_subnet_1         = local.vpc.subnets[1].cidr
  egress_subnet_2         = local.single_az_mode ? local.vpc.subnets[1].cidr : local.vpc.subnets[3].cidr
  single_az_mode          = false
  single_az_ha            = true
  ha_gw                   = true
  az1                     = "a"
  az2                     = "b"
  enable_egress_transit_firenet = var.transit_module.transit_gateway.enable_egress_transit_firenet
}
