
resource "azurerm_subnet" "subnet" {
  for_each                                       = var.subnets
  name                                           = each.value["name"]
  resource_group_name                            = each.value["resourcegroup"]
  address_prefixes                               = each.value["address_prefixes"]
  virtual_network_name                           = each.value["vnet"]
  service_endpoints                              = try(each.value["service_endpoints"], null)
  enforce_private_link_endpoint_network_policies = try(each.value["enforce_private_link_endpoint_network_policies"], false)
  enforce_private_link_service_network_policies  = try(each.value["enforce_private_link_service_network_policies"], false)

  dynamic "delegation" {
    for_each = lookup(each.value, "delegations", null) != null ? [1] : []

    content {
      name = each.value.delegations.name

      service_delegation {
        name    = each.value.delegations.service_delegation
        actions = lookup(each.value.delegations, "actions", null)
      }
    }
  }
}
