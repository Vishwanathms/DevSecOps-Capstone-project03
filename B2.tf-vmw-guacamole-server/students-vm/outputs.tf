output "student_vms" {
  value = [
    for vm in vsphere_virtual_machine.student_vm :
    vm.default_ip_address
  ]
}

