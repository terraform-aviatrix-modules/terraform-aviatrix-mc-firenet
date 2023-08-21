In this example, the module deploys the transit VPC and a HA pair of Aviatrix transit gateways in GCP (mc-transit module).
On top of that, Firenet is deployed with the mc-firenet module, deploying a pair of Palo Alto firewalls and enabling egress traffic to the internet.

```hcl
module "transit_ha_gcp" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.5.0"

  cloud                  = "gcp"
  name                   = "transit-ha-gcp"
  region                 = "us-east1"
  cidr                   = "10.2.0.0/23"
  account                = "GCP"
  enable_transit_firenet = true
  lan_cidr               = "10.102.0.0/24"
}

module "mc_firenet_ha_gcp" {
  source  = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version = "1.5.2"

  transit_module = module.transit_ha_gcp
  firewall_image = "Palo Alto Networks VM-Series Next-Generation Firewall BUNDLE1"
  egress_enabled = true
  egress_cidr    = "10.102.1.0/24"
  mgmt_cidr      = "10.102.3.0/24"
}
```