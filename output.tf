output "aviatrix_firenet" {
  description = "The Aviatrix firenet object with all of it's attributes"
  value       = aviatrix_firenet.firenet
}

output "aviatrix_firewall_instance" {
  description = "A list with the created firewall instances and their attributes"
  value = (
    local.ha_gw ?
    (local.is_aviatrix ?                                                                                         #Evaluate if var.ha_gw is true
      concat(aviatrix_gateway.egress_instance_1.*, aviatrix_gateway.egress_instance_2.*)                         #Output if local.is_aviatrix is true
      :                                                                                                          #
      concat(aviatrix_firewall_instance.firewall_instance_1.*, aviatrix_firewall_instance.firewall_instance_2.*) #Output if local.is_aviatrix is false
    )                                                                                                            #
    :                                                                                                            #
    (local.is_aviatrix ?                                                                                         #Evaluate if var.ha_gw is false
      [aviatrix_gateway.egress_instance[0]]                                                                      #Output if local.is_aviatrix is true
      :                                                                                                          #
      [aviatrix_firewall_instance.firewall_instance[0]]                                                          #Output if local.is_aviatrix is false
    )
  )
}
