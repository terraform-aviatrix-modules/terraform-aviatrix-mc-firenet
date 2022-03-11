data "aviatrix_firewall_instance_images" "fw_images" {
  vpc_id = var.transit_module.vpc.vpc_id
}