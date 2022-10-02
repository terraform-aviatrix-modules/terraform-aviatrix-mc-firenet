In this example, the module deploys the transit VPC and a HA pair of Aviatrix transit gateways in AWS (mc-transit module).
On top of that, Firenet is deployed with the mc-firenet module, deploying 2 FortiGate firewalls and enabling egress traffic to the internet.

```hcl
module "transit_ha_aws" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "v2.3.0"

  cloud                  = "aws"
  name                   = "transit-ha-aws"
  region                 = "eu-central-1"
  cidr                   = "10.2.0.0/23"
  account                = "AWS"
  enable_transit_firenet = true
}

module "mc_firenet_ha_aws" {
  source  = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version = "v1.3.0"

  transit_module = module.transit_ha_aws
  firewall_image = "Fortinet FortiGate Next-Generation Firewall"
  egress_enabled = true
}
```