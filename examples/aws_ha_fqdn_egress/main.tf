module "mc_transit_ha_aws_fqdn" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.0.0"

  cloud                  = "aws"
  name                   = "transit-ha-fqdn-aws"
  region                 = "eu-central-1"
  cidr                   = "10.3.0.0/23"
  account                = "AWS"
  enable_transit_firenet = true
}

module "mc_firenet_ha_aws_fqdn" {
  source  = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version = "1.0.1"

  transit_module = module.transit_ha_aws_fqdn
  firewall_image = "aviatrix"
  fw_amount      = 4
}