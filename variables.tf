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

  validation {
    condition     = var.fw_amount % 2 == 0
    error_message = "Please set fw_amount to an even number. Odd numbers are not supported. If you just want to deploy a single NGFW instance, disabling ha_gw on the transit module will achieve that."
  }  
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
  description = "Map of tags to assign to the firewall instances."
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

variable "username" {
  description = "Username to be configured for NGFW instance"
  type        = string
  default     = null
}

variable "password" {
  description = "Firewall instance password"
  type        = string
  default     = "Aviatrix#1234"
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
}

variable "storage_access_key_2" {
  description = "The storage_access_key to access the storage account"
  type        = string
  default     = ""
}

variable "file_share_folder_2" {
  description = "The file_share_folder containing the bootstrap files"
  type        = string
  default     = ""
}

variable "mgmt_cidr" {
  description = "The CIDR range to be used for the Management VPC for Firenet in GCP"
  type        = string
  default     = ""

  validation {
    condition     = var.mgmt_cidr != "" ? can(cidrnetmask(var.mgmt_cidr)) : true
    error_message = "This does not like a valid CIDR."
  }
}

variable "egress_cidr" {
  description = "The CIDR range to be used for the Egress VPC for Firenet in GCP"
  type        = string
  default     = ""

  validation {
    condition     = var.egress_cidr != "" ? can(cidrnetmask(var.egress_cidr)) : true
    error_message = "This does not like a valid CIDR."
  }
}

locals {
  #Gather transit module details in locals, for easy reference
  transit_gateway               = var.transit_module.transit_gateway
  vpc                           = var.transit_module.vpc
  account                       = var.transit_module.transit_gateway.account_name
  region                        = var.transit_module.mc_firenet_details.region
  ha_region                     = var.transit_module.mc_firenet_details.ha_region
  single_az_mode                = var.transit_module.mc_firenet_details.single_az_mode
  single_az_ha                  = var.transit_module.mc_firenet_details.single_az_ha
  ha_gw                         = var.transit_module.mc_firenet_details.ha_gw
  az1                           = var.transit_module.mc_firenet_details.az1
  az2                           = var.transit_module.mc_firenet_details.az2
  zone                          = var.transit_module.mc_firenet_details.zone
  ha_zone                       = var.transit_module.mc_firenet_details.ha_zone
  name                          = var.transit_module.mc_firenet_details.name
  cloud                         = var.transit_module.mc_firenet_details.cloud
  availability_domain           = var.transit_module.mc_firenet_details.availability_domain
  fault_domain                  = var.transit_module.mc_firenet_details.fault_domain
  ha_availability_domain        = var.transit_module.mc_firenet_details.ha_availability_domain
  ha_fault_domain               = var.transit_module.mc_firenet_details.ha_fault_domain
  lan_vpc                       = var.transit_module.mc_firenet_details.lan_vpc
  enable_transit_firenet        = var.transit_module.transit_gateway.enable_transit_firenet
  enable_egress_transit_firenet = var.transit_module.transit_gateway.enable_egress_transit_firenet

  is_checkpoint            = length(regexall("check point", lower(var.firewall_image))) > 0                                         #Check if fw image is Checkpoint. Needs special handling for username in Azure
  is_palo                  = length(regexall("palo", lower(var.firewall_image))) > 0                                                #Check if fw image is palo. Needs special handling for management_subnet (CP & Fortigate null)
  is_aviatrix              = length(regexall("aviatrix", lower(var.firewall_image))) > 0                                            #Check if fw image is Aviatrix FQDN Egress
  bootstrap_bucket_name_2  = length(var.bootstrap_bucket_name_2) > 0 ? var.bootstrap_bucket_name_2 : var.bootstrap_bucket_name_1    #If bucket 2 name is not provided, fallback to bucket 1.
  iam_role_2               = length(var.iam_role_2) > 0 ? var.iam_role_2 : var.iam_role_1                                           #If IAM role 2 name is not provided, fallback to IAM role 1.
  user_data_2              = length(var.user_data_2) > 0 ? var.user_data_2 : var.user_data_1                                        #If user data 2 name is not provided, fallback to user data 1.
  bootstrap_storage_name_2 = length(var.bootstrap_storage_name_2) > 0 ? var.bootstrap_storage_name_2 : var.bootstrap_storage_name_1 #If storage 2 name is not provided, fallback to storage name 1.
  storage_access_key_2     = length(var.storage_access_key_2) > 0 ? var.storage_access_key_2 : var.storage_access_key_1             #If storage 1 key is not provided, fallback to storage key 1.
  file_share_folder_2      = length(var.file_share_folder_2) > 0 ? var.file_share_folder_2 : var.file_share_folder_1                #If storage 2 folder is not provided, fallback to folder 1.

  #Customize vpc_id per cloud
  vpc_id = lookup(local.vpc_id_map, local.cloud, local.vpc.vpc_id)
  vpc_id_map = {
    gcp = format("%s~-~%s", local.vpc.vpc_id, data.aviatrix_account.default.gcloud_project_id)
  }

  #Determine egress subnets
  gcp_egress_subnet = local.cloud == "gcp" ? format("%s~~%s~~%s", aviatrix_vpc.egress_vpc[0].subnets[0].cidr, aviatrix_vpc.egress_vpc[0].subnets[0].region, aviatrix_vpc.egress_vpc[0].subnets[0].name) : null

  egress_subnet_1 = (
    (local.cloud == "gcp" ?
      local.gcp_egress_subnet
      :
      local.vpc.public_subnets[local.egress_subnet_map[local.cloud]].cidr
    )
  )

  egress_subnet_2 = (
    (local.single_az_mode ?
      local.egress_subnet_1
      :
      (local.cloud == "gcp" ?
        local.gcp_egress_subnet
        :
        local.vpc.public_subnets[local.egress_ha_subnet_map[local.cloud]].cidr
      )
    )
  )

  egress_subnet_map = {
    azure = 0,
    aws   = 1,
    oci   = 2,
  }

  egress_ha_subnet_map = {
    azure = 1,
    aws   = 3,
    oci   = 0,
  }

  #Determine mgmt subnets
  gcp_mgmt_subnet = local.cloud == "gcp" && local.is_palo ? format("%s~~%s~~%s", aviatrix_vpc.management_vpc[0].subnets[0].cidr, aviatrix_vpc.management_vpc[0].subnets[0].region, aviatrix_vpc.management_vpc[0].subnets[0].name) : null
  mgmt_subnet_1 = (
    (local.is_palo ?
      (local.cloud == "gcp" ?
        local.gcp_mgmt_subnet
        :
        local.vpc.public_subnets[local.mgmt_subnet_map[local.cloud]].cidr
      )
      :
      null
    )
  )

  mgmt_subnet_2 = (
    (local.is_palo ?
      (local.single_az_mode ?
        local.mgmt_subnet_1
        :
        (local.cloud == "gcp" ?
          local.gcp_mgmt_subnet
          :
          local.vpc.public_subnets[local.mgmt_ha_subnet_map[local.cloud]].cidr
        )
      )
      :
      null
    )
  )

  mgmt_subnet_map = {
    azure = 2,
    aws   = 0,
    oci   = 3,
  }

  mgmt_ha_subnet_map = {
    azure = 3,
    aws   = 2,
    oci   = 1,
  }

  #Determine firewall image version if not Aviatrix FQDN egress GW
  firewall_image_data     = local.is_aviatrix ? null : [for i in data.aviatrix_firewall_instance_images.fw_images.firewall_images.* : i if i.firewall_image == var.firewall_image]
  latest_firewall_version = local.is_aviatrix ? null : local.firewall_image_data[0].firewall_image_version[0]
  firewall_image_version  = local.is_aviatrix ? null : coalesce(var.firewall_image_version, local.latest_firewall_version)

  #Determine firewall instance size
  instance_size = coalesce(var.instance_size, local.instance_size_map[local.cloud])
  instance_size_map = {
    azure = "Standard_D3_v2",
    aws   = "c5.xlarge",
    gcp   = "n1-standard-4",
    oci   = "VM.Standard2.4",
  }

  #Determine firewall username and password
  username = var.username == null ? lookup(local.username_map, local.cloud, null) : var.username
  username_map = {
    azure = local.is_checkpoint ? "admin" : "fwadmin",
  }

  password = local.cloud == "azure" ? var.password : null

  #Determine FW Amount
  fw_amount_per_instance = var.fw_amount / 2
  fw_amount_instance_1   = local.ha_gw ? local.fw_amount_per_instance : 1
  fw_amount_instance_2   = local.ha_gw ? local.fw_amount_per_instance : 0
}
