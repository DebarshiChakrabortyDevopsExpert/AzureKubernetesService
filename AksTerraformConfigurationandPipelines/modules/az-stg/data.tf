data "azurerm_client_config" "current" {}
## Subnet for private endpoint
data "azurerm_subnet" "subnet_private_endpoint" {
    for_each             = var.storage_pvt_endpnt
    name                 = each.value.subnet_name
    virtual_network_name = each.value.vnet_name
    resource_group_name  = each.value.vnet_rg_name
}
