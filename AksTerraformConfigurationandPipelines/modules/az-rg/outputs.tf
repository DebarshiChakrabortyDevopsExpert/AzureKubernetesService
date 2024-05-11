output "resource_group_ids" {
  description = "Returns a map of resource_group key -> resource_group id"
  depends_on = [azurerm_resource_group.rg]

  value = {
    for group in keys(azurerm_resource_group.rg):
     group => azurerm_resource_group.rg[group].id
}
}
