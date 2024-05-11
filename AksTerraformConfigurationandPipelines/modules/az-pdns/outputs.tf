output "privatedns_ids" {
  description = "Returns a map of privatedns_ids key -> privatedns_ids"
  depends_on  = [azurerm_private_dns_zone.private_dns]
  value = {
    for group in keys(azurerm_private_dns_zone.private_dns) :
    group => azurerm_private_dns_zone.private_dns[group].id
  }
}

output "privatednszone_vnetlink_ids" {
  description = "Returns a map of privatednszone_vnetlink_ids key -> privatednszone_vnetlink_ids"
  depends_on  = [azurerm_private_dns_zone_virtual_network_link.vnet_links]
  value = {
    for group in keys(azurerm_private_dns_zone_virtual_network_link.vnet_links) :
    group => azurerm_private_dns_zone_virtual_network_link.vnet_links[group].id
  }
}

