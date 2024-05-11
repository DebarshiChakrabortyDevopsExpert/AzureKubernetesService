# Module for creating Virtual Networks
resource "azurerm_virtual_network" "vnet" {
  for_each            = var.virtual_networks
  name                = each.value["name"]
  location            = each.value["location"]
  resource_group_name = each.value["resourcegroup"]
  address_space       = each.value["address_space"]
  dns_servers         = lookup(each.value, "dns_servers", null)
 
  dynamic "ddos_protection_plan" {

    for_each = lookup(each.value,"ddos_protection_plan", null) != null ? [1] : []
    content {
      id     = data.azurerm_network_ddos_protection_plan.vnet[each.key].id
      enable = each.value.ddos_protection_plan.enable

    }

  }

  tags = try(each.value["az_tags"], null)
}
