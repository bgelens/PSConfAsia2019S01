variable "publicip" {
  default     = false
  description = "add public ip address to the VM NIC."
}

variable "vmname" {
  type        = "string"
  description = "the name of the VM."
}

variable "location" {
  type        = "string"
  description = "the location to deploy to."
}

variable "resource_group_name" {
  type        = "string"
  description = "the resource group name where to deploy in."
}

variable "subnetid" {
  type        = "string"
  description = "the subnetid where to attach the VM NIC to."
}

variable "vmsize" {
  type        = "string"
  description = "the size of the VM."
  default     = "Standard_DS1_v2"
}

variable "adminname" {
  type        = "string"
  description = "the administrator username for the vm."
}

variable "adminpassword" {
  type        = "string"
  description = "the administrator password for the VM."
}

variable "enableoms" {
  default = false
}

variable "omsworkspaceid" {
  type        = "string"
  description = "the OMS Workspace ID to target the OMS VM extension to."
  default     = ""
}

variable "omskey" {
  type        = "string"
  description = "the OMS access key."
  default     = ""
}

variable "enableantimalware" {
  default = false
}

variable "enablediskencryption" {
  default = false
}

variable "diskencryption_volume_type" {
  description = "when enablediskencryption is set to true, define if 'os', 'data' or 'all' disks should be encrypted."
  default     = "all"
  type        = "string"
}

variable "diskencryption_keyvault_url" {
  description = "when enablediskencryption is set to true, define the url of the keyvault where to store the secret."
  type        = "string"
  default     = ""
}

variable "diskencryption_keyvault_id" {
  description = "when enablediskencryption is set to true, define the resource id of the keyvault where to store the secret."
  type        = "string"
  default     = ""
}
