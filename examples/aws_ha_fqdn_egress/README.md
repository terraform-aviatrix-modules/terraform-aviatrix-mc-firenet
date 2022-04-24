In this example, the module deploys the transit VPC and a HA pair of Aviatrix transit gateways in AWS (mc-transit module).
On top of that, Firenet is deployed with the mc-firenet module, deploying 4 Aviatrix FQDN egress gateways for filtering traffic to the internet.

```
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

  transit_module  = module.transit_ha_aws_fqdn
  firewall_image  = "aviatrix"
  fw_amount       = 4
}
```