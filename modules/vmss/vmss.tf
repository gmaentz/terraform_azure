#########
# WebServers
resource "random_string" "fqdn" {
 length  = 6
 special = false
 upper   = false
 number  = false
}

resource "azurerm_public_ip" "vmss" {
 name                         = "vmss-public-ip"
 location                     = "${var.location}"
 resource_group_name          = "${var.resource_group_name}"
 public_ip_address_allocation = "static"
 domain_name_label            = "${random_string.fqdn.result}"
 tags                         = "${var.tags}"
}

resource "azurerm_lb" "vmss" {
 name                = "vmss-lb"
 location            = "${var.location}"
 resource_group_name = "${var.resource_group_name}"

 frontend_ip_configuration {
   name                 = "PublicIPAddress"
   public_ip_address_id = "${azurerm_public_ip.vmss.id}"
 }

 tags = "${var.tags}"
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
 resource_group_name = "${var.resource_group_name}"
 loadbalancer_id     = "${azurerm_lb.vmss.id}"
 name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "vmss" {
 resource_group_name = "${var.resource_group_name}"
 loadbalancer_id     = "${azurerm_lb.vmss.id}"
 name                = "ssh-running-probe"
 port                = "${var.application_port}"
}

resource "azurerm_lb_rule" "lbnatrule" {
   resource_group_name            = "${var.resource_group_name}"
   loadbalancer_id                = "${azurerm_lb.vmss.id}"
   name                           = "http"
   protocol                       = "Tcp"
   frontend_port                  = "${var.application_port}"
   backend_port                   = "${var.application_port}"
   backend_address_pool_id        = "${azurerm_lb_backend_address_pool.bpepool.id}"
   frontend_ip_configuration_name = "PublicIPAddress"
   probe_id                       = "${azurerm_lb_probe.vmss.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# THE CUSTOM DATA SCRIPT THAT WILL RUN ON EACH SERVER NODE WHEN IT'S BOOTING
# This script will configure and start our webserver
# ---------------------------------------------------------------------------------------------------------------------

# data "template_file" "custom_data_server" {
#   template = "${file("${path.module}/webclient.sh")}"

#   vars {
#     cluster_name   = "${var.cluster_name}"
#   }
# }

resource "azurerm_virtual_machine_scale_set" "vmss" {
 name                = "${var.cluster_name}"
 location            = "${var.location}"
 resource_group_name = "${var.resource_group_name}"
 upgrade_policy_mode = "Manual"

 sku {
   name     = "${var.instance_type}"
   tier     = "Standard"
   capacity = "${var.cluster_size}"
 }

 storage_profile_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "16.04-LTS"
   version   = "latest"
 }

#  storage_profile_image_reference {
#    publisher = "OpenLogic"
#    offer     = "CentOS"
#    sku       = "7-CI"
#    version   = "latest"
#  }

 storage_profile_os_disk {
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 storage_profile_data_disk {
   lun          = 0
   caching        = "ReadWrite"
   create_option  = "Empty"
   disk_size_gb   = 10
 }

 os_profile {
   computer_name_prefix = "vmlab"
   admin_username       = "${var.admin_user}"
   admin_password       = "${var.admin_password}"
   custom_data          = "${file("web.conf")}"
   # custom_data          = "${data.template_file.custom_data_server.rendered}"
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 network_profile {
   name    = "terraformnetworkprofile"
   primary = true

   ip_configuration {
     name                                   = "IPConfiguration"
     subnet_id                              = "${var.subnet_id}"
     load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.bpepool.id}"]
   }
 }
}

#JUMP Server

resource "azurerm_public_ip" "jumpbox" {
 name                         = "jumpbox-public-ip"
 location                     = "${var.location}"
 resource_group_name          = "${var.resource_group_name}"
 public_ip_address_allocation = "static"
 domain_name_label            = "${random_string.fqdn.result}-ssh"
 tags                         = "${var.tags}"
}

resource "azurerm_network_interface" "jumpbox" {
 name                = "jumpbox-nic"
 location            = "${var.location}"
 resource_group_name = "${var.resource_group_name}"

 ip_configuration {
   name                          = "IPConfiguration"
   subnet_id                     = "${var.subnet_id}"
   private_ip_address_allocation = "dynamic"
   public_ip_address_id          = "${azurerm_public_ip.jumpbox.id}"
 }

 tags = "${var.tags}"
}

resource "azurerm_virtual_machine" "jumpbox" {
 name                  = "jumpbox"
 location              = "${var.location}"
 resource_group_name   = "${var.resource_group_name}"
 network_interface_ids = ["${azurerm_network_interface.jumpbox.id}"]
 vm_size               = "Standard_D1_v2"

 storage_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "16.04-LTS"
   version   = "latest"
 }

 storage_os_disk {
   name              = "jumpbox-osdisk"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 os_profile {
   computer_name  = "jumpbox"
   admin_username = "${var.admin_user}"
   admin_password = "${var.admin_password}"
   custom_data    = "${file("web.conf")}"
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 tags = "${var.tags}"
}