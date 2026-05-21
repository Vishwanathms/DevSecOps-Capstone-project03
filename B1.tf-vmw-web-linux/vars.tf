variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}

variable "datacenter" {}
variable "cluster" {}
variable "datastore" {}
variable "network" {}

variable "template_name" {}
variable "vm_name" {}

variable "vm_ip" {}
variable "vm_gateway" {}
variable "vm_netmask" {
  default = "24"
}