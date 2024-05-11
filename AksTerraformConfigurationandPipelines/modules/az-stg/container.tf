resource "azurerm_storage_container" "blob_container" {
    for_each              = var.blob_containers
    name                  = each.value.container_name
    storage_account_name  = each.value.storage_account_name
    container_access_type = each.value.container_access_type
    depends_on = [azurerm_storage_account.stgaccount]    
}