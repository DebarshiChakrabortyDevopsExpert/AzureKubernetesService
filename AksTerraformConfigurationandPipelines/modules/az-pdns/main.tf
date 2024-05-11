resource "azurerm_private_dns_zone" "private_dns" {
  for_each            = var.private_dns
  name                = each.value["name"]
  resource_group_name = each.value["resource_group_name"]
  tags                = try(each.value["az_tags"], null)
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_links" {
  for_each              = var.vnet_links
  name                  = each.value["name"]
  resource_group_name   = each.value["resource_group_name"]
  private_dns_zone_name = each.value["private_dns_zone_name"]
  virtual_network_id    = data.azurerm_virtual_network.vnet[each.key].id
  registration_enabled  = try(each.value["registration_enabled"], null)
  tags                  = try(each.value["az_tags"], null)
  depends_on = [
    azurerm_private_dns_zone.private_dns
  ]
}