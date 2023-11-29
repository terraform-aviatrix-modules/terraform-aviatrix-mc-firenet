#Additional VPC's for GCP Firenet

# Management VPC
resource "aviatrix_vpc" "management_vpc" {
  count                = local.cloud == "gcp" && local.is_palo ? 1 : 0 #Only create for Palo Alto deployments in GCP
  cloud_type           = 4
  account_name         = local.account
  name                 = "${substr(local.name, 0, 25)}-mgmt"
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false

  subnets {
    name   = "${local.name}-mgmt"
    cidr   = var.mgmt_cidr
    region = local.region
  }
}

# Egress VPC
resource "aviatrix_vpc" "egress_vpc" {
  count                = local.cloud == "gcp" ? 1 : 0 #Only create for GCP and when firenet is enabled
  cloud_type           = 4
  account_name         = local.account
  name                 = "${substr(local.name, 0, 23)}-egress"
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
  subnets {
    name   = "${local.name}-egress"
    cidr   = var.egress_cidr
    region = local.region
  }
}

#Firewall instances
resource "aviatrix_firewall_instance" "firewall_instance_1" {
  count                  = local.is_aviatrix ? 0 : local.fw_amount_instance_1
  firewall_name          = try(var.custom_fw_names[count.index], "${local.name}-az1-fw${count.index + 1}")
  firewall_size          = local.instance_size
  vpc_id                 = local.vpc.vpc_id
  firewall_image         = var.firewall_image
  firewall_image_version = local.firewall_image_version
  egress_subnet          = local.egress_subnet_1
  firenet_gw_name        = local.transit_gateway.gw_name
  management_subnet      = local.mgmt_subnet_1
  zone                   = local.use_gwlb ? local.az1 : (contains(["azure", "gcp"], local.cloud) ? local.zone : null)
  firewall_image_id      = var.firewall_image_id
  tags                   = var.tags
  username               = local.username
  password               = local.password
  ssh_public_key         = local.ssh_public_key
  sic_key                = var.sic_key
  key_name               = var.key_name
  availability_domain    = local.availability_domain
  fault_domain           = local.fault_domain
  management_vpc_id      = local.is_palo && local.cloud == "gcp" ? aviatrix_vpc.management_vpc[0].vpc_id : null
  egress_vpc_id          = local.cloud == "gcp" ? aviatrix_vpc.egress_vpc[0].vpc_id : null

  #Bootstrapping
  bootstrap_storage_name = var.bootstrap_storage_name_1
  storage_access_key     = var.storage_access_key_1
  file_share_folder      = var.file_share_folder_1
  user_data              = var.user_data_1
  iam_role               = var.iam_role_1
  bootstrap_bucket_name  = var.bootstrap_bucket_name_1

  lifecycle {
    ignore_changes = [
      firewall_image_version, #Do not replace FW instance, when latest image version changes
      firewall_size,          #Do not replace FW instance, after out of band resizing of instance
      tags,                   #Do not replace FW instance when changing tags
    ]
  }
}

resource "aviatrix_firewall_instance" "firewall_instance_2" {
  count                  = local.is_aviatrix ? 0 : local.fw_amount_instance_2
  firewall_name          = try(var.custom_fw_names[length(var.custom_fw_names) / 2 + count.index], "${local.name}-az2-fw${count.index + 1}")
  firewall_size          = local.instance_size
  vpc_id                 = local.vpc.vpc_id
  firewall_image         = var.firewall_image
  firewall_image_version = local.firewall_image_version
  egress_subnet          = local.egress_subnet_2
  firenet_gw_name        = local.transit_gateway.ha_gw_name
  management_subnet      = local.mgmt_subnet_2
  zone                   = local.use_gwlb ? local.az2 : (contains(["azure", "gcp"], local.cloud) ? local.ha_zone : null)
  firewall_image_id      = var.firewall_image_id
  tags                   = var.tags
  username               = local.username
  password               = local.password
  ssh_public_key         = local.ssh_public_key
  sic_key                = var.sic_key
  key_name               = var.key_name
  availability_domain    = local.ha_availability_domain
  fault_domain           = local.ha_fault_domain
  management_vpc_id      = local.is_palo && local.cloud == "gcp" ? aviatrix_vpc.management_vpc[0].vpc_id : null
  egress_vpc_id          = local.cloud == "gcp" ? aviatrix_vpc.egress_vpc[0].vpc_id : null

  #Bootstrapping
  bootstrap_storage_name = local.bootstrap_storage_name_2
  storage_access_key     = local.storage_access_key_2
  file_share_folder      = local.file_share_folder_2
  user_data              = local.user_data_2
  iam_role               = local.iam_role_2
  bootstrap_bucket_name  = local.bootstrap_bucket_name_2

  lifecycle {
    ignore_changes = [
      firewall_image_version, #Do not replace FW instance, when latest image version changes
      firewall_size,          #Do not replace FW instance, after out of band resizing of instance
      tags,                   #Do not replace FW instance when changing tags
    ]
  }
}

#FQDN Egress filtering instances
resource "aviatrix_gateway" "egress_instance_1" {
  count               = local.is_aviatrix ? local.fw_amount_instance_1 : 0
  cloud_type          = local.transit_gateway.cloud_type
  account_name        = local.account
  gw_name             = try(var.custom_fw_names[count.index], "${local.name}-az1-egress-gw${count.index + 1}")
  vpc_id              = local.cloud == "gcp" ? aviatrix_vpc.egress_vpc[0].vpc_id : local.vpc.vpc_id
  vpc_reg             = local.cloud == "gcp" ? local.zone : local.region
  gw_size             = local.instance_size
  subnet              = local.egress_subnet_1
  single_az_ha        = local.single_az_ha
  tags                = var.tags
  availability_domain = local.availability_domain
  fault_domain        = local.fault_domain
  fqdn_lan_vpc_id     = local.fqdn_lan_vpc_id
  fqdn_lan_cidr       = local.fqdn_lan_cidr
  lifecycle {
    ignore_changes = [
      enable_vpc_dns_server # aviatrix_fqdn gw_filter_tag_list modifies this value on the gateway
    ]
  }
}

resource "aviatrix_gateway" "egress_instance_2" {
  count               = local.is_aviatrix ? local.fw_amount_instance_2 : 0
  cloud_type          = local.transit_gateway.cloud_type
  account_name        = local.account
  gw_name             = try(var.custom_fw_names[length(var.custom_fw_names) / 2 + count.index], "${local.name}-az2-egress-gw${count.index + 1}")
  vpc_id              = local.cloud == "gcp" ? aviatrix_vpc.egress_vpc[0].vpc_id : local.vpc.vpc_id
  vpc_reg             = local.cloud == "gcp" ? local.ha_zone : local.region
  gw_size             = local.instance_size
  subnet              = local.egress_subnet_2
  single_az_ha        = local.single_az_ha
  tags                = var.tags
  availability_domain = local.ha_availability_domain
  fault_domain        = local.ha_fault_domain
  fqdn_lan_vpc_id     = local.fqdn_lan_vpc_id
  fqdn_lan_cidr       = local.ha_fqdn_lan_cidr
  lifecycle {
    ignore_changes = [
      enable_vpc_dns_server # aviatrix_fqdn gw_filter_tag_list modifies this value on the gateway
    ]
  }
}

#Firenet
resource "aviatrix_firenet" "firenet" {
  vpc_id                               = local.vpc.vpc_id
  inspection_enabled                   = local.is_aviatrix || local.enable_egress_transit_firenet ? false : var.inspection_enabled #Always switch to false if Aviatrix FQDN egress or egress transit firenet.
  egress_enabled                       = local.is_aviatrix || local.enable_egress_transit_firenet ? true : var.egress_enabled      #Always switch to true if Aviatrix FQDN egress or egress transit firenet.
  keep_alive_via_lan_interface_enabled = var.keep_alive_via_lan_interface_enabled
  egress_static_cidrs                  = var.egress_static_cidrs
  east_west_inspection_excluded_cidrs  = var.east_west_inspection_excluded_cidrs
  hashing_algorithm                    = var.hashing_algorithm

  depends_on = [
    aviatrix_firewall_instance_association.firenet_instance1,
    aviatrix_firewall_instance_association.firenet_instance2,
    aviatrix_gateway.egress_instance_1,
    aviatrix_gateway.egress_instance_2,
  ]
}

resource "aviatrix_firewall_instance_association" "firenet_instance1" {
  count           = var.associated ? local.fw_amount_instance_1 : 0
  vpc_id          = local.vpc.vpc_id
  firenet_gw_name = local.transit_gateway.gw_name
  instance_id     = local.is_aviatrix ? aviatrix_gateway.egress_instance_1[count.index].gw_name : aviatrix_firewall_instance.firewall_instance_1[count.index].instance_id
  firewall_name   = local.is_aviatrix || local.cloud == "gcp" ? null : aviatrix_firewall_instance.firewall_instance_1[count.index].firewall_name
  lan_interface = (local.is_aviatrix ?
    (local.cloud == "azure" ?
      aviatrix_gateway.egress_instance_1[count.index].fqdn_lan_interface
      :
      null
    )
    :
    aviatrix_firewall_instance.firewall_instance_1[count.index].lan_interface
  )
  management_interface = local.is_aviatrix ? null : aviatrix_firewall_instance.firewall_instance_1[count.index].management_interface
  egress_interface     = local.is_aviatrix ? null : aviatrix_firewall_instance.firewall_instance_1[count.index].egress_interface
  vendor_type          = local.is_aviatrix ? "fqdn_gateway" : null
  attached             = var.attached
}

resource "aviatrix_firewall_instance_association" "firenet_instance2" {
  count           = var.associated ? local.fw_amount_instance_2 : 0
  vpc_id          = local.vpc.vpc_id
  firenet_gw_name = local.transit_gateway.ha_gw_name
  instance_id     = local.is_aviatrix ? aviatrix_gateway.egress_instance_2[count.index].gw_name : aviatrix_firewall_instance.firewall_instance_2[count.index].instance_id
  firewall_name   = local.is_aviatrix || local.cloud == "gcp" ? null : aviatrix_firewall_instance.firewall_instance_2[count.index].firewall_name
  lan_interface = (local.is_aviatrix ?
    (local.cloud == "azure" ?
      aviatrix_gateway.egress_instance_2[count.index].fqdn_lan_interface
      :
      null
    )
    :
    aviatrix_firewall_instance.firewall_instance_2[count.index].lan_interface
  )
  management_interface = local.is_aviatrix ? null : aviatrix_firewall_instance.firewall_instance_2[count.index].management_interface
  egress_interface     = local.is_aviatrix ? null : aviatrix_firewall_instance.firewall_instance_2[count.index].egress_interface
  vendor_type          = local.is_aviatrix ? "fqdn_gateway" : null
  attached             = var.attached
}
