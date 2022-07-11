module "transit_non_ha_azure" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "v2.1.5"

  cloud                  = "azure"
  name                   = "transit-azure-non-ha"
  region                 = "West Europe"
  cidr                   = "10.1.0.0/23"
  account                = "Azure"
  ha_gw                  = false
  enable_transit_firenet = true
}

module "mc_firenet_non_ha_azure" {
  source  = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version = "v1.1.2"

  transit_module = module.transit_non_ha_azure
  firewall_image = "Check Point CloudGuard IaaS Single Gateway R80.40 - Pay As You Go (NGTP)"
  egress_enabled = true
}