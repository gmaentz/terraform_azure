#Connect to Azure
# Configure the Azure Provider
provider "azurerm" {}

# Authenticate with Azure and Create a Resource Group
# Set through CLI or env variables - 
# How To: https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html


# Create a resource group
resource "azurerm_resource_group" "network" {
  name     = "devtest"
  location = "eastus2"
}

#Build out my Network
module "network" {
    source              = "Azure/network/azurerm"
    resource_group_name = "${azurerm_resource_group.network.name}"
    location            = "${azurerm_resource_group.network.location}"
    address_space       = "10.0.0.0/16"
    subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    subnet_names        = ["subnet1", "subnet2", "subnet3"]

    tags                = {
                            owner = "user"
                            environment = "dev-environment"
                          }
}

# Deploy the Fleet
module "webserver_cluster" {
    source = "../../modules/services/vmss"
    location =  "${azurerm_resource_group.network.location}"
    resource_group_name = "${azurerm_resource_group.network.name}"
    virtual_network_name = "${module.network.vnet_name}"
    subnet_id = "${module.network.vnet_subnets[0]}"
    application_port = 80
    admin_user = "azureuser"
    admin_password = "AzureAdminP@ssword1"
    cluster_name = "webserver-dev"
    cluster_size = "2"
    #image = ""
    #key_name = "MyOregonSSH"
    instance_type = "Standard_D1_v2"
    tags                = {
                            owner = "user"
                            environment = "dev-environment"
                          }
 }

# module "cloud_watch" {
#   source = "github.com/gmaentz/terraform/modules/services/cloud-watch"
#   sms_number = "${var.sms_number}"
#   autoscaling_group = "${module.webserver_cluster.asg_name}"