#East West transit Firenet
module "transit_ha_dual_firenet_aws_east_west" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "v2.1.3"

  cloud                  = "aws"
  name                   = "transit-ha-aws-east-west"
  region                 = "eu-central-1"
  cidr                   = "10.2.0.0/23"
  account                = "AWS"
  enable_transit_firenet = true
}

module "mc_firenet_ha_dual_firenet_aws_east_west" {
  source  = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version = "v1.1.1"

  transit_module = module.transit_ha_dual_firenet_aws_east_west
  firewall_image = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
}

#Egress transit Firenet
module "transit_ha_dual_firenet_aws_egress" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "v2.1.3"

  cloud                         = "aws"
  name                          = "transit-ha-aws-egress"
  region                        = "eu-central-1"
  cidr                          = "10.4.0.0/23"
  account                       = "AWS"
  enable_egress_transit_firenet = true
}

module "mc_firenet_ha_dual_firenet_aws_egress" {
  source  = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version = "v1.1.1"

  transit_module = module.transit_ha_dual_firenet_aws_egress
  firewall_image = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
}

#Spoke VPC
module "spoke_aws_1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.2.1"

  cloud             = "AWS"
  name              = "App1"
  cidr              = "10.100.0.0/24"
  region            = "eu-central-1"
  account           = "AWS"
  transit_gw        = module.transit_ha_dual_firenet_aws_east_west.transit_gateway.gw_name
  transit_gw_egress = module.transit_ha_dual_firenet_aws_egress.transit_gateway.gw_name
}
