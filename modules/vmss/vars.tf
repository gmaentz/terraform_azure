variable "application_port" {
   description = "The port that you want to expose to the external load balancer"
   #default     = 80
}

variable "admin_user" {
   description = "User name to use as the admin account on the VMs that will be part of the VM Scale Set"
}

variable "admin_password" {
   description = "Default password for admin account"
}

variable "location" {
   description = "Location of the resource group"
}
variable "resource_group_name" {
   description = "Resource group name"
}

variable "virtual_network_name" {
   description = "Virtual network name"
}

variable "subnet_id" {
   description = "ID of Subnet"
}

variable "cluster_name" {
   description = "Name of the server cluster/vmss"
}

variable "instance_type" {
   description = "The type of instance/sku"
}
variable "cluster_size" {
   description = "The size of the cluster"
}

variable "tags" {
 description = "A map of the tags to use for the resources that are deployed"
 type        = "map"
}