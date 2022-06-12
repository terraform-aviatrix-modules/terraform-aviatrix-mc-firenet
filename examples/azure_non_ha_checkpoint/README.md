In this example, the module deploys the transit VNET and a single Aviatrix transit gateway in Azure (mc-transit module).
On top of that, Firenet is deployed with the mc-firenet module, deploying a single Checkpoint firewall and enabling egress traffic to the internet.

```
module "transit_non_ha_azure" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "v2.1.3"

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
  version = "v1.1.1"

  transit_module = module.transit_non_ha_azure
  firewall_image = "Check Point CloudGuard IaaS Single Gateway R80.40 - Pay As You Go (NGTP)"
  egress_enabled = true
}
```