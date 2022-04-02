terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
  }
}

module "transit_non_ha_gcp" {
  source = "git::https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit.git" #Needs to be version pinned after mc-transit 2.0 release

  cloud                  = "gcp"
  name                   = "transit-non-ha-gcp"
  region                 = "us-east1"
  cidr                   = "10.1.0.0/23"
  account                = "GCP"
  ha_gw                  = false
  enable_transit_firenet = true
  lan_cidr               = "10.101.0.0/24"
}

module "mc_firenet_non_ha_gcp" {
  source = "../.."

  transit_module = module.transit_non_ha_gcp
  firewall_image = "Fortinet FortiGate Next-Generation Firewall"
  egress_enabled = true
  egress_cidr    = "10.101.1.0/24"
}

variable "custom_fw_names" {
  type = list(string)
  default = [
    "az1-fw1",
    "az1-fw2",
    "az2-fw1",
    "az2-fw2",
  ]
}

module "transit_ha_gcp" {
  source = "git::https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit.git" #Needs to be version pinned after mc-transit 2.0 release

  cloud                  = "gcp"
  name                   = "transit-ha-gcp"
  region                 = "us-east1"
  cidr                   = "10.2.0.0/23"
  account                = "GCP"
  enable_transit_firenet = true
  lan_cidr               = "10.102.0.0/24"
}

module "mc_firenet_ha_gcp" {
  source = "../.."

  transit_module = module.transit_ha_gcp
  firewall_image = "Fortinet FortiGate Next-Generation Firewall"
  egress_enabled = true
  egress_cidr    = "10.102.1.0/24"
}

#Add test assertions.
# resource "test_assertions" "public_ip_non_ha" {
#   component = "public_ip_non_ha_gcp"

#   check "fw_public_ip" {
#     description = "NGFW has public IP"
#     condition   = can(cidrnetmask("${module.mc_firenet_non_ha_gcp.aviatrix_firewall_instance[0].public_ip}/32"))
#   }
# }

# resource "test_assertions" "public_ip_ha" {
#   component = "public_ip_ha_gcp"

#   check "fw1_public_ip" {
#     description = "NGFW 1 has valid IP"
#     condition   = can(cidrnetmask("${module.mc_firenet_ha_gcp.aviatrix_firewall_instance[0].public_ip}/32"))
#   }

#   check "fw2_public_ip" {
#     description = "NGFW 2 has valid IP"
#     condition   = can(cidrnetmask("${module.mc_firenet_ha_gcp.aviatrix_firewall_instance[1].public_ip}/32"))
#   }
# }

# resource "test_assertions" "egress_subnet_allocation_non_ha" {
#   component = "egress_subnet_allocation_non_ha_gcp"

#   equal "egress_subnet_allocation_ngfw" {
#     description = "Check NGFW is in correct egress subnet."
#     got         = module.mc_firenet_non_ha_gcp.aviatrix_firewall_instance[0].egress_subnet
#     want        = module.transit_non_ha_gcp.vpc.public_subnets[1].cidr
#   }
# }

# resource "test_assertions" "egress_subnet_allocation_ha" {
#   component = "egress_subnet_allocation_ha_gcp"

#   equal "egress_subnet_allocation_ngfw1" {
#     description = "Check NGFW 1 is in correct egress subnet."
#     got         = module.mc_firenet_ha_gcp.aviatrix_firewall_instance[0].egress_subnet
#     want        = module.transit_ha_gcp.vpc.public_subnets[1].cidr
#   }

#   equal "egress_subnet_allocation_ngfw2" {
#     description = "Check NGFW 2 is in correct egress subnet."
#     got         = module.mc_firenet_ha_gcp.aviatrix_firewall_instance[1].egress_subnet
#     want        = module.transit_ha_gcp.vpc.public_subnets[1].cidr
#   }
# }

# resource "test_assertions" "custom_fw_name_ha" {
#   component = "custom_fw_name_ha_gcp"

#   equal "custom_fw_name_ngfw1" {
#     description = "Check NGFW 1 custom FW name."
#     got         = module.mc_firenet_ha_gcp.aviatrix_firewall_instance[0].firewall_name
#     want        = var.custom_fw_names[0]
#   }

#   equal "custom_fw_name_ngfw2" {
#     description = "Check NGFW 2 custom FW name."
#     got         = module.mc_firenet_ha_gcp.aviatrix_firewall_instance[1].firewall_name
#     want        = var.custom_fw_names[1]
#   }
# }
