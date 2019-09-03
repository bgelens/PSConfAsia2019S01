output "vmresourceid" {
  value = "${azurerm_virtual_machine.vm.id}"
}

output "privateip" {
  value = "${azurerm_network_interface.nic.private_ip_address}"
}
