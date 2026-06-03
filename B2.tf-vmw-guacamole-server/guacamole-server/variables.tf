variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}

variable "datacenter" {}
variable "cluster" {}
variable "datastore" {}
variable "network" {}
variable "template_name" {}

variable "domain" {
  default = "lab.local"
}

variable "vm_gateway" {}
variable "vm_netmask" {
  default = 24
}

variable "dns_servers" {
  type = list(string)
}

variable "student_vm_count" {
  default = 3
}

variable "student_vm_cpu" {
  default = 2
}

variable "student_vm_ram" {
  default = 4096
}

variable "student_vm_disk" {
  default = 40
}   