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

resource "test_assertions" "cloud_type_non_ha" {
  component = "cloud_type_non_ha"

  equal "cloud_type_non_ha_gcp" {
    description = "Module output is equal to check map."
    got         = module.transit_non_ha_gcp.transit_gateway.cloud_type
    want        = 4
  }
}

resource "test_assertions" "cloud_type_ha" {
  component = "cloud_type_ha"

  equal "cloud_type_ha_gcp" {
    description = "Module output is equal to check map."
    got         = module.transit_ha_gcp.transit_gateway.cloud_type
    want        = 4
  }
}
