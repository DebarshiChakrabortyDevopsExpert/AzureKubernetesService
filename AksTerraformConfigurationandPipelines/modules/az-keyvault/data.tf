data "azurerm_client_config" "current" {}
## Subnet for private endpoint
data "azurerm_subnet" "subnet_private_endpoint" {
    for_each             = var.key_vault_pvt_endpnt
    name                 = each.value.subnet_name
    virtual_network_name = each.value.vnet_name
    resource_group_name  = each.value.vnet_rg_name
}


# data "azurerm_subnet" "subnet_service_endpoint" {
#     # for_each             = var.keyvaults.network_acls
#     for_each = {
#         for k,v in try(var.keyvaults, {}) : k => v
#         if try(v.network, null) != null
#     }
#     name                 = var.keyvaults.network.subnet_name
#     virtual_network_name = var.keyvaults.network.vnet_name
#     resource_group_name  = var.keyvaults.network.vnet_rg_name
# }