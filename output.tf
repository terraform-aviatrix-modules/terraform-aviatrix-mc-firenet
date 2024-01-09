output "aviatrix_firenet" {
  description = "The Aviatrix firenet object with all of it's attributes"
  value       = aviatrix_firenet.firenet
}

output "aviatrix_firewall_instance" {
  description = "A list with the created firewall instances and their attributes"
  value = (
    local.is_aviatrix ?                                                                                        #Evaluate local.is_aviatrix
    concat(aviatrix_gateway.egress_instance_1.*, aviatrix_gateway.egress_instance_2.*)                         #Output if local.is_aviatrix is true
    :                                                                                                          #
    concat(aviatrix_firewall_instance.firewall_instance_1.*, aviatrix_firewall_instance.firewall_instance_2.*) #Output if local.is_aviatrix is false
  )
}

output "module_metadata" {
  value = {
    version = "1.4.4"
  }
}
