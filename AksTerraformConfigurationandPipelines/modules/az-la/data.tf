data "azurerm_log_analytics_workspace" "law" {
    for_each = try(var.log_analytics_solutions , {})
    name                = each.value.log_analytics_workspace_name
    resource_group_name = each.value.resource_group_name
    
    depends_on = [
      azurerm_log_analytics_workspace.log_analytics
    ]
}