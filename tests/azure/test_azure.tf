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

module "transit_non_ha_azure" {
  source = "git::https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit.git" #Needs to be version pinned after mc-transit 2.0 release

  cloud                  = "azure"
  name                   = "transit-non-ha-azure"
  region                 = "West Europe"
  cidr                   = "10.1.0.0/23"
  account                = "Azure"
  ha_gw                  = false
  enable_transit_firenet = true
}

module "mc_firenet_non_ha_azure" {
  source = "../.."

  transit_module = module.transit_non_ha_azure
  firewall_image = "Fortinet FortiGate (PAYG) Next-Generation Firewall"
  egress_enabled = true
}

module "transit_ha_azure" {
  source = "git::https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit.git" #Needs to be version pinned after mc-transit 2.0 release

  cloud                  = "azure"
  name                   = "transit-ha-azure"
  region                 = "West Europe"
  cidr                   = "10.2.0.0/23"
  account                = "Azure"
  enable_transit_firenet = true
}

module "mc_firenet_ha_azure" {
  source = "../.."

  transit_module = module.transit_ha_azure
  firewall_image = "Fortinet FortiGate (PAYG) Next-Generation Firewall"
  egress_enabled = true
}

resource "test_assertions" "cloud_type_non_ha" {
  component = "cloud_type_non_ha_azure"

  equal "cloud_type_non_ha" {
    description = "Module output is equal to check map."
    got         = module.transit_non_ha_azure.transit_gateway.cloud_type
    want        = 8
  }
}

resource "test_assertions" "cloud_type_ha" {
  component = "cloud_type_ha_azure"

  equal "cloud_type_ha" {
    description = "Module output is equal to check map."
    got         = module.transit_ha_azure.transit_gateway.cloud_type
    want        = 8
  }
}
