provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server

  allow_unverified_ssl = true
}

# Datacenter
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

# Datastore
data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Cluster
data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Network
data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Template
data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.dc.id
}

# data "vsphere_folder" "vm_folder" {
#   path          = var.vm_folder
# }


# resource "vsphere_folder" "dev" {
#   path          = "dev"
#   type          = "vm"
#   datacenter_id = data.vsphere_datacenter.dc.id
# }

resource "vsphere_folder" "kube" {
  path          = "dev/swarm"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# VM Creation
resource "vsphere_virtual_machine" "vm" {
  count = length(var.vm_name)
  name             = "${var.vm_name[count.index]}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  #folder = data.vsphere_folder.vm_folder.path
  folder = vsphere_folder.kube.path

  num_cpus = var.cpu
  memory   = var.memory
  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = 500
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

  }

  extra_config = {
    "guestinfo.userdata" = base64encode(templatefile("${path.module}/cloud-init.yaml", {
      hostname = var.vm_name[count.index]
      ssh_key  = file("~/.ssh/id_rsa.pub")
    }))
    "guestinfo.userdata.encoding" = "base64"
  }
}
