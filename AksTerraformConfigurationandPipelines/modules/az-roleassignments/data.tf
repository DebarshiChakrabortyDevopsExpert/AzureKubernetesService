data "azurerm_user_assigned_identity" "uami" {
   for_each = {
    for k,v in try(var.role_assignments, {}) : k => v
    if try(v.principle_id_name, null) != null
  } 
  name                   = each.value.principle_id_name
  resource_group_name    = each.value.principle_id_rg

}