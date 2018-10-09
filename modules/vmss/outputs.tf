#FQDN
output "vmss_public_fqdn" {
     value = "${azurerm_public_ip.vmss.fqdn}"
 }

#Load Balancer
 output "lb_dns_name" {
   value = "${azurerm_lb.vmss.id}"
 }
# #VMSS Name
 output "vmss_name" {
   value = "${azurerm_virtual_machine_scale_set.vmss.name}"
 }

 #Path
output "jumpbox_public_fqdn" {
     value = "${azurerm_public_ip.jumpbox.fqdn}"
 }