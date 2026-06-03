output "guacamole_url" {
  value = "http://${vsphere_virtual_machine.guacamole.default_ip_address}:8080/guacamole"
}

output "guacamole_ip" {
  value = vsphere_virtual_machine.guacamole.default_ip_address
}
