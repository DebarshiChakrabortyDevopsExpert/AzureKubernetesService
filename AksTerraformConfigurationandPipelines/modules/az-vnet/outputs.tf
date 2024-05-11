output "vnet_ids" {
  description = "Returns a map of resource_group key -> resource_group id"
  depends_on  = [azurerm_virtual_network.vnet]
  value = {
    for group in keys(azurerm_virtual_network.vnet) :
    group => azurerm_virtual_network.vnet[group].id
  }
}

output "vnet_guids" {
  description = "Returns a map of resource_group key -> resource_group id"
  depends_on  = [azurerm_virtual_network.vnet]
  value = {
    for group in keys(azurerm_virtual_network.vnet) :
    group => azurerm_virtual_network.vnet[group].guid
  }
}