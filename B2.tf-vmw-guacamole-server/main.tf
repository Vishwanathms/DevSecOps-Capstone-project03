data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_folder" "web-ubuntu" {
  path          = "dev/web-ubuntu"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# =========================================================
# MYSQL SERVER
# =========================================================

# resource "vsphere_virtual_machine" "mysql" {

#   name             = "mysql-server"
#   resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
#   datastore_id     = data.vsphere_datastore.datastore.id

#   num_cpus = 2
#   memory   = 4096
#   guest_id = data.vsphere_virtual_machine.template.guest_id

#   scsi_type = "pvscsi"

#   network_interface {
#     network_id   = data.vsphere_network.network.id
#     adapter_type = "vmxnet3"
#   }

#   disk {
#     label            = "disk0"
#     size             = 500
#     thin_provisioned = true
#   }

#   clone {
#     template_uuid = data.vsphere_virtual_machine.template.id

#     # customize {
#     #   linux_options {
#     #     host_name = "mysql"
#     #     domain    = var.domain
#     #   }

#     #   network_interface {
#     #     ipv4_address = "192.168.1.220"
#     #     ipv4_netmask = var.vm_netmask
#     #   }

#     #   ipv4_gateway    = var.vm_gateway
#     #   dns_server_list = var.dns_servers
#     # }
#   }

#   extra_config = {
#     "guestinfo.userdata"          = base64encode(file("${path.module}/cloud-init/mysql.yaml"))
#     "guestinfo.userdata.encoding" = "base64"
#   }
# }

# =========================================================
# GUACAMOLE SERVER
# =========================================================

resource "vsphere_virtual_machine" "guacamole" {

  name             = "guacamole-server"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 4096
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = "pvscsi"

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = 500
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    # customize {
    #   linux_options {
    #     host_name = "guacamole"
    #     domain    = var.domain
    #   }

    #   network_interface {
    #     ipv4_address = "192.168.1.222"
    #     ipv4_netmask = var.vm_netmask
    #   }

    #   ipv4_gateway    = var.vm_gateway
    #   dns_server_list = var.dns_servers
    # }
  }

  # extra_config = {
  #   "guestinfo.userdata" = base64encode(templatefile(
  #     "${path.module}/cloud-init/guacamole.yaml.tftpl",
  #     {
  #       mysql_ip = vsphere_virtual_machine.mysql.default_ip_address
  #     }
  #   ))

  #   "guestinfo.userdata.encoding" = "base64"
  # }

  extra_config = {
    "guestinfo.userdata"          = base64encode(file("${path.module}/cloud-init/guacamole.yaml"))
    "guestinfo.userdata.encoding" = "base64"
  }
}


# =========================================================
# STUDENT MACHINES
# =========================================================

resource "vsphere_virtual_machine" "student_vm" {

  count = var.student_vm_count

  name             = "student-vm-${count.index + 1}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.student_vm_cpu
  memory   = var.student_vm_ram

  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = "pvscsi"

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = "500"
    thin_provisioned = true
  }

  clone {

    template_uuid = data.vsphere_virtual_machine.template.id

    # customize {

    #   linux_options {
    #     host_name = "student-${count.index + 1}"
    #     domain    = var.domain
    #   }

    #   network_interface {
    #     ipv4_address = "192.168.1.${230 + count.index}"
    #     ipv4_netmask = var.vm_netmask
    #   }

    #   ipv4_gateway    = var.vm_gateway
    #   dns_server_list = var.dns_servers
    # }
  }

  extra_config = {
    "guestinfo.userdata"          = base64encode(file("${path.module}/cloud-init/student.yaml"))
    "guestinfo.userdata.encoding" = "base64"
  }
}