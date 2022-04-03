data "aviatrix_account" "default" {
  account_name = local.account

  depends_on = [
    local.account,
  ]
}

data "aviatrix_firewall_instance_images" "fw_images" {
  vpc_id = local.vpc_id

  depends_on = [
    local.vpc,
  ]
}
