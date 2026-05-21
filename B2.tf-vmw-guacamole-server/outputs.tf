output "guacamole_url" {
  value = "http://${vsphere_virtual_machine.guacamole.default_ip_address}:8080/guacamole"
}

output "guacamole_ip" {
  value = vsphere_virtual_machine.guacamole.default_ip_address
}

output "student_vms" {
  value = [
    for vm in vsphere_virtual_machine.student_vm :
    vm.default_ip_address
  ]
}

output "mysql_data_path" {
  value = "/opt/guacamole/mysql-data"
}
