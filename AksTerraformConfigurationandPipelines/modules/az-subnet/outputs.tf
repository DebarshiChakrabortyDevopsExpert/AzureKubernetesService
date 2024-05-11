output "subnet_ids" {
  description = "Returns a map of subnet_ids key -> subnet_ids"
  depends_on  = [azurerm_subnet.subnet]
  value = {
    for group in keys(azurerm_subnet.subnet) :
    group => azurerm_subnet.subnet[group].id
  }
}

output "subnet_service_endpoints" {
  description = "Returns a map of subnet_service_endpoints key -> subnet_service_endpoints"
  depends_on  = [azurerm_subnet.subnet]
  value = {
    for group in keys(azurerm_subnet.subnet) :
    group => azurerm_subnet.subnet[group].service_endpoints
  }
}

output "subnet_enforce_private_link_endpoint_network_policies" {
  description = "Returns a map of subnet_enforce_private_link_endpoint_network_policies key -> subnet_enforce_private_link_endpoint_network_policies"
  depends_on  = [azurerm_subnet.subnet]
  value = {
    for group in keys(azurerm_subnet.subnet) :
    group => azurerm_subnet.subnet[group].enforce_private_link_endpoint_network_policies
  }
}

output "subnet_enforce_private_link_service_network_policies" {
  description = "Returns a map of subnet_enforce_private_link_service_network_policies key -> subnet_enforce_private_link_service_network_policies"
  depends_on  = [azurerm_subnet.subnet]
  value = {
    for group in keys(azurerm_subnet.subnet) :
    group => azurerm_subnet.subnet[group].enforce_private_link_service_network_policies
  }
}