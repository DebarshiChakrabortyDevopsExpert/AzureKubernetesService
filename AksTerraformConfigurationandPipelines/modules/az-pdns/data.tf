data "azurerm_virtual_network" "vnet" {
    for_each            = var.vnet_links
    name                = each.value["vnet_name"]
    resource_group_name = each.value["vnet_rg"]
}