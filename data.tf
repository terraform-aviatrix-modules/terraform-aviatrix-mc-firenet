data "aviatrix_firewall_instance_images" "fw_images" {
  vpc_id = local.vpc.vpc_id

  depends_on = [
    local.vpc,
  ]
}
