data "aviatrix_firewall_instance_images" "fw_images" {
  vpc_id = local.vpc_id

  depends_on = [
    local.transit_gateway,
  ]
}
