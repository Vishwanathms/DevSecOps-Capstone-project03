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

locals {
  students_csv_header = "batch_id,student_id,student_name,email,vm_name,vm_ip,"

  students_csv_rows = [
    for idx, vm in vsphere_virtual_machine.student_vm :
    "${var.batch_id},${format("%03d", idx + 1)},Student${idx + 1},Student${idx + 1}@b3.com,stuvm${format("%02d", idx + 1)},${vm.default_ip_address},"
  ]

  students_csv_content = "${local.students_csv_header}\n${join("\n", local.students_csv_rows)}"
}


# =========================================================
# STUDENT MACHINES
# =========================================================

resource "vsphere_virtual_machine" "student_vm" {

  count = var.student_vm_count

  name             = "labvm${count.index + 1}"
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
    size             = "100"
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

  # extra_config = {
  #   "guestinfo.userdata"          = base64encode(file("${path.module}/cloud-init/student.yaml"))
  #   "guestinfo.userdata.encoding" = "base64"
  # }
  extra_config = {
    "guestinfo.userdata" = base64encode(
      templatefile("${path.module}/cloud-init/student.yaml.tpl", {
        vm_name = "labvm${count.index + 1}"
      })
    )

    "guestinfo.userdata.encoding" = "base64"
  }
}