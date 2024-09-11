# data "aviatrix_firewall_instance_images" "fw_images" {
#   vpc_id = local.vpc_id

#   depends_on = [
#     local.transit_gateway, #makes sure the VPC is created and the Aviatrix transit gateway deployed, before trying to query the available images.
#   ]
# }
