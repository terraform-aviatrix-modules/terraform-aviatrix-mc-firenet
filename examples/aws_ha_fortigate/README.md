```
module "transit_ha_aws" {
  source = "git@github.com:terraform-aviatrix-modules/terraform-aviatrix-mc-transit.git" #Needs to be version pinned after mc-transit 2.0 release

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
```