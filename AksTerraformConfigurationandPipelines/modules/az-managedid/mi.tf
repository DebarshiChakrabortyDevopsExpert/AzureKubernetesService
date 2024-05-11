resource "azurerm_user_assigned_identity" "managedid" {
    for_each            = var.managed_ids
    name                = each.value.managedid_name
    location            = each.value.location
    resource_group_name = each.value.resource_group_name
    tags                = try(each.value.tags, null)
}