resource "azurerm_role_assignment" "role_assignments" {
    for_each                = var.role_assignments
    name                    = each.value.name
    scope                   = each.value.scope
    role_definition_id      = try(each.value.role_definition_id, null)
    role_definition_name    = try(each.value.role_definition_name, null)
    principal_id            = data.azurerm_user_assigned_identity.uami[each.key].principal_id
    description             = try(each.value.description, null)
}