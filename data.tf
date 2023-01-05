data "aviatrix_firewall_instance_images" "fw_images" {
  count  = local.get_default_firewall_image ? 0 : 1
  vpc_id = local.vpc.vpc_id

  depends_on = [
    local.vpc,
  ]
}
