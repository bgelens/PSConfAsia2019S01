resource "azurerm_public_ip" "vmpip" {
  count                        = "${var.publicip ? 1 : 0}"
  name                         = "${var.vmname}-pip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vmname}-nic"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "configuration1"
    subnet_id                     = "${var.subnetid}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${join("", azurerm_public_ip.vmpip.*.id)}"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                             = "${var.vmname}"
  location                         = "${var.location}"
  resource_group_name              = "${var.resource_group_name}"
  network_interface_ids            = ["${azurerm_network_interface.nic.id}"]
  vm_size                          = "${var.vmsize}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vmname}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.vmname}"
    admin_username = "${var.adminname}"
    admin_password = "${var.adminpassword}"
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }
}

resource "azurerm_virtual_machine_extension" "Server_Log_Analytics" {
  count                      = "${var.enableoms ? 1 : 0}"
  name                       = "OMSExtension"
  location                   = "${var.location}"
  resource_group_name        = "${var.resource_group_name}"
  virtual_machine_name       = "${var.vmname}"
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  depends_on                 = ["azurerm_virtual_machine.vm"]

  settings = <<SETTINGS
  {
    "workspaceId": "${var.omsworkspaceid}"
  }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "workspaceKey": "${var.omskey}"
  }
  PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "IaaSAntimalware" {
  count                      = "${var.enableantimalware ? 1 : 0}"
  name                       = "IaaSAntimalware"
  location                   = "${var.location}"
  resource_group_name        = "${var.resource_group_name}"
  virtual_machine_name       = "${var.vmname}"
  publisher                  = "Microsoft.Azure.Security"
  type                       = "IaaSAntimalware"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true
  depends_on                 = ["azurerm_virtual_machine.vm"]

  settings = <<SETTINGS
  {
    "AntimalwareEnabled": true,
    "RealtimeProtectionEnabled": "true",
    "ScheduledScanSettings": {
        "isEnabled": "true",
        "day": "7",
        "time": "120",
        "scanType": "Quick"
    },
    "Exclusions": {
        "Extensions": "",
        "Paths": "",
        "Processes": ""
    }
  }
  SETTINGS
}

resource "azurerm_virtual_machine_extension" "AzureDiskEncryption" {
  count                      = "${var.enablediskencryption ? 1 : 0}"
  name                       = "AzureDiskEncryption"
  location                   = "${var.location}"
  resource_group_name        = "${var.resource_group_name}"
  virtual_machine_name       = "${var.vmname}"
  publisher                  = "Microsoft.Azure.Security"
  type                       = "AzureDiskEncryption"
  type_handler_version       = "2.2"
  auto_upgrade_minor_version = true
  depends_on                 = ["azurerm_virtual_machine.vm"]

  settings = <<SETTINGS
  {
      "EncryptionOperation": "EnableEncryption",
      "KeyVaultURL": "${var.diskencryption_keyvault_url}",
      "KeyVaultResourceId": "${var.diskencryption_keyvault_id}",
      "KeyEncryptionAlgorithm": "RSA-OAEP",
      "VolumeType": "${var.diskencryption_volume_type}"
  }
  SETTINGS
}
