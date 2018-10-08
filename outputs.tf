#DNS Name
 output "vmss_dns_name" {
     value = "${module.webserver_cluster.vmss_public_fqdn}"
 }

# VPC
output "network_name" {
  description = "The network name"
  value       = "${module.network.vnet_address_space}"
}
# Subnets
output "subnets" {
  description = "List of subnets"
  value       = ["${module.network.vnet_subnets}"]
}

# #VMSS Name
 output "vmss_name" {
   value = "${module.webserver_cluster.vmss_name}"
 }
 output "jumpbox_dns_name" {
   value = "${module.webserver_cluster.jumpbox_public_fqdn}"
 }

# #Security Group
# output "elb_security_group_id" {
#   value = "${module.webserver_cluster.elb_security_group_id}"
# }