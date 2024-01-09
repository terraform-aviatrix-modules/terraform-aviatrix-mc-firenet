
variable "region" {
  default = "West Europe"
}

variable "name" {
  default = "transit"
}

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.region
}

resource "azurerm_route_table" "this" {
  for_each            = toset(["aviatrix-transit-gw_rtb", "egress1-rtb", "egress2-rtb"])
  name                = each.value
  location            = var.region
  resource_group_name = azurerm_resource_group.this.name

  route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  lifecycle {
    ignore_changes = [route, ] #Ignore changes to routing tables, as the Aviatrix controller will take over management.
  }
}

module "vnet" {
  source              = "Azure/vnet/azurerm"
  vnet_name           = var.name
  vnet_location       = var.region
  use_for_each        = true
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.1.0.0/16"]
  subnet_prefixes = [
    "10.1.101.0/24",
    "10.1.102.0/24",
    "10.1.103.0/24",
    "10.1.104.0/24",
  ]
  subnet_names = [
    "Public1",
    "Public2",
    "Egress1",
    "Egress2",
  ]

  route_tables_ids = {
    Public1 = azurerm_route_table.this["aviatrix-transit-gw_rtb"].id #Using a different route table name for transit gateways causes drift. Make sure to use "aviatrix-<transit_vnet_name>-gw_rtb".
    Public2 = azurerm_route_table.this["aviatrix-transit-gw_rtb"].id #Using a different route table name for transit gateways causes drift. Make sure to use "aviatrix-<transit_vnet_name>-gw_rtb".
    Egress1 = azurerm_route_table.this["egress1-rtb"].id
    Egress2 = azurerm_route_table.this["egress2-rtb"].id
  }
}

module "azure_transit" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.4.3"

  cloud                  = "azure"
  region                 = var.region
  account                = "Azure"
  enable_transit_firenet = true

  use_existing_vpc = true
  vpc_id           = format("%s:%s:%s", module.vnet.vnet_name, azurerm_resource_group.this.name, module.vnet.vnet_guid)
  gw_subnet        = "10.1.101.0/24" #Public subnet
  hagw_subnet      = "10.1.102.0/24" #Public subnet

  depends_on = [module.vnet]
}

module "firenet" {
  source  = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version = "v1.4.4"

  transit_module = module.azure_transit
  firewall_image = "Check Point CloudGuard IaaS Single Gateway R80.40 - Bring Your Own License"
  egress_enabled = true

  egress_subnet_1 = "10.1.103.0/24"
  egress_subnet_2 = "10.1.104.0/24"
}
