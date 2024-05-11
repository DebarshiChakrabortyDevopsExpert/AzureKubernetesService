## Private endpoint for function app
resource "azurerm_private_endpoint" "private_endpoint_storage" {
  for_each            = var.storage_pvt_endpnt
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  subnet_id           = data.azurerm_subnet.subnet_private_endpoint[each.key].id
  tags                = try(each.value.tags, null)

  private_service_connection {
    name                           = each.value.private_connection_name
    private_connection_resource_id = azurerm_storage_account.stgaccount.id
    is_manual_connection           = try(each.value.is_manual_connection, false)
    subresource_names              = try(each.value.subresource_names,null)
  }

  dynamic "private_dns_zone_group" {
    for_each = try(each.value.private_dns_zone_group, null) != null ? [each.value.private_dns_zone_group] : []
    content {
      name                 = try(private_dns_zone_group.value.name, null)
      private_dns_zone_ids = flatten([for ids, value in try(private_dns_zone_group.value.dnszones, null) : "/subscriptions/${value.subscription_id}/resourceGroups/${value.dns_zone_rg_name}/providers/Microsoft.Network/privateDnsZones/${value.dns_zone_name}"])
    }
  }

  depends_on = [ 
    azurerm_storage_container.blob_container,
  ]
}
