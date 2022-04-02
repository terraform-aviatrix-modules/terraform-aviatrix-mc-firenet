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

module "transit_non_ha_oci" {
  source = "git::https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit.git" #Needs to be version pinned after mc-transit 2.0 release

  cloud                  = "oci"
  name                   = "transit-non-ha-oci"
  region                 = "us-ashburn-1"
  cidr                   = "10.1.0.0/23"
  account                = "OCI"
  ha_gw                  = false
  enable_transit_firenet = true
}

module "mc_firenet_non_ha_oci" {
  source = "../.."

  transit_module = module.transit_non_ha_oci
  firewall_image = "Palo Alto Networks VM-Series Next Generation Firewall"
  egress_enabled = true
}

variable "custom_fw_names" {
  type = list(string)
  default = [
    "az1-fw1",
    "az2-fw1",
  ]
}

module "transit_ha_oci" {
  source = "git::https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit.git" #Needs to be version pinned after mc-transit 2.0 release

  cloud                  = "oci"
  name                   = "transit-ha-oci"
  region                 = "us-ashburn-1"
  cidr                   = "10.2.0.0/23"
  account                = "OCI"
  enable_transit_firenet = true
}

module "mc_firenet_ha_oci" {
  source = "../.."

  transit_module  = module.transit_ha_oci
  firewall_image  = "Palo Alto Networks VM-Series Next Generation Firewall"
  egress_enabled  = true
  custom_fw_names = var.custom_fw_names
}


resource "test_assertions" "public_ip_non_ha" {
  component = "public_ip_non_ha_oci"

  check "fw_public_ip" {
    description = "NGFW has public IP"
    condition   = can(cidrnetmask("${module.mc_firenet_non_ha_oci.aviatrix_firewall_instance[0].public_ip}/32"))
  }
}

resource "test_assertions" "public_ip_ha" {
  component = "public_ip_ha_oci"

  check "fw1_public_ip" {
    description = "NGFW 1 has valid IP"
    condition   = can(cidrnetmask("${module.mc_firenet_ha_oci.aviatrix_firewall_instance[0].public_ip}/32"))
  }

  check "fw2_public_ip" {
    description = "NGFW 2 has valid IP"
    condition   = can(cidrnetmask("${module.mc_firenet_ha_oci.aviatrix_firewall_instance[1].public_ip}/32"))
  }
}

resource "test_assertions" "egress_subnet_allocation_non_ha" {
  component = "egress_subnet_allocation_non_ha_oci"

  equal "egress_subnet_allocation_ngfw" {
    description = "Check NGFW is in correct egress subnet."
    got         = module.mc_firenet_non_ha_oci.aviatrix_firewall_instance[0].egress_subnet
    want        = module.transit_non_ha_oci.vpc.public_subnets[2].cidr
  }
}

resource "test_assertions" "egress_subnet_allocation_ha" {
  component = "egress_subnet_allocation_ha_oci"

  equal "egress_subnet_allocation_ngfw1" {
    description = "Check NGFW 1 is in correct egress subnet."
    got         = module.mc_firenet_ha_oci.aviatrix_firewall_instance[0].egress_subnet
    want        = module.transit_ha_oci.vpc.public_subnets[2].cidr
  }

  equal "egress_subnet_allocation_ngfw2" {
    description = "Check NGFW 2 is in correct egress subnet."
    got         = module.mc_firenet_ha_oci.aviatrix_firewall_instance[1].egress_subnet
    want        = module.transit_ha_oci.vpc.public_subnets[0].cidr
  }
}

resource "test_assertions" "custom_fw_name_ha" {
  component = "custom_fw_name_ha_oci"

  equal "custom_fw_name_ngfw1" {
    description = "Check NGFW 1 custom FW name."
    got         = module.mc_firenet_ha_oci.aviatrix_firewall_instance[0].firewall_name
    want        = var.custom_fw_names[0]
  }

  equal "custom_fw_name_ngfw2" {
    description = "Check NGFW 2 custom FW name."
    got         = module.mc_firenet_ha_oci.aviatrix_firewall_instance[1].firewall_name
    want        = var.custom_fw_names[1]
  }
}
