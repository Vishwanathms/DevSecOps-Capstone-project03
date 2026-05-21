variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}

variable "datacenter" {}
variable "datastore" {}
variable "cluster" {}
variable "network" {}
variable "template" {}

variable "vm_name" {
    type = list(string)
    
}
variable "cpu" {}
variable "memory" {}
variable "disk_size" {}

variable "domain" {}
#variable "ip" {}
#variable "netmask" {}
#variable "gateway" {}
variable "vm_folder" {}

