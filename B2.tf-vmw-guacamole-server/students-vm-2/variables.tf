variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}

variable "datacenter" {}
variable "cluster" {}
variable "datastore" {}
variable "network" {}
variable "template_name" {}

variable "batch_id" {
  type    = string
  default = "netdevops-jul26"
}

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
  default = 30
}

variable "student_vm_cpu" {
  default = 4
}

variable "student_vm_ram" {
  default = 8096
}

variable "student_vm_disk" {
  default = 40
}   