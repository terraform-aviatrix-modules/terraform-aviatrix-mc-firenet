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

module "transit_non_ha_aws" {
  source = "git::https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit.git" #Needs to be version pinned after mc-transit 2.0 release

  cloud                  = "aws"
  name                   = "transit-non-ha-aws"
  region                 = "eu-central-1"
  cidr                   = "10.1.0.0/23"
  account                = "AWS"
  ha_gw                  = false
  enable_transit_firenet = true
}

module "mc_firenet_non_ha_aws" {
  source = "../.."

  transit_module = module.transit_non_ha_aws
  firewall_image = "Fortinet FortiGate Next-Generation Firewall"
  egress_enabled = true
}

module "transit_ha_aws" {
  source = "git::https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit.git" #Needs to be version pinned after mc-transit 2.0 release

  cloud                  = "aws"
  name                   = "transit-ha-aws"
  region                 = "eu-central-1"
  cidr                   = "10.2.0.0/23"
  account                = "AWS"
  enable_transit_firenet = true
}

module "mc_firenet_ha_aws" {
  source = "../.."

  transit_module = module.transit_ha_aws
  firewall_image = "Fortinet FortiGate Next-Generation Firewall"
  egress_enabled = true
}

resource "test_assertions" "cloud_type_non_ha" {
  component = "cloud_type_non_ha_aws"

  equal "cloud_type_non_ha" {
    description = "Module output is equal to check map."
    got         = module.transit_non_ha_aws.transit_gateway.cloud_type
    want        = 1
  }
}

resource "test_assertions" "cloud_type_ha" {
  component = "cloud_type_ha_aws"

  equal "cloud_type_ha" {
    description = "Module output is equal to check map."
    got         = module.transit_ha_aws.transit_gateway.cloud_type
    want        = 1
  }
}
