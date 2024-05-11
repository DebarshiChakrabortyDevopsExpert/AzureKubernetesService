data "azurerm_network_ddos_protection_plan" "vnet" {
  
   for_each = {
        for key, value in try(var.virtual_networks, {}) : key => value
        if try(value.ddos_plan_name, null) != null
    }
  name                = each.value.ddos_plan_name
  resource_group_name = each.value.ddos_plan_rg
}