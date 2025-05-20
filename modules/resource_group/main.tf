
variable "name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where the resource group will be created"
  type        = string
}

variable "rg_name" {
  description = "Alternative name of the resource group"
  type        = string
  default     = ""
}

resource "azurerm_resource_group" "rg" {
  name     = coalesce(var.rg_name, var.name)
  location = var.location
}

output "name" {
  value = azurerm_resource_group.rg.name
}

output "id" {
  value = azurerm_resource_group.rg.id
}

output "location" {
  value = azurerm_resource_group.rg.location
}
