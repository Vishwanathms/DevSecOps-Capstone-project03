output "student_vms" {
  value = [
    for vm in vsphere_virtual_machine.student_vm :
    vm.default_ip_address
  ]
}

# output "students_csv_file" {
#   value = local_file.students_csv.filename
# }

# output "students_csv_content" {
#   value = local.students_csv_content
# }

