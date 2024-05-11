resource "azurerm_log_analytics_workspace" "log_analytics" {
    for_each                   = var.log_analytics

    name                       = each.value.name
    location                   = each.value.location
    resource_group_name        = each.value.resource_group_name
    sku                        = try(each.value.sku, "PerGB2018")
    retention_in_days          = try(each.value.retention_in_days, 30)
    daily_quota_gb             = try(each.value.daily_quota_gb, null)
    internet_ingestion_enabled = try(each.value.internet_ingestion_enabled, null)
    internet_query_enabled     = try(each.value.internet_query_enabled , null)
    tags                       = try(each.value.tags, null)
}

resource "azurerm_log_analytics_solution" "log_analytics" {
for_each = try(var.log_analytics_solutions , {})

    solution_name         = each.value.solution_name
    location              = each.value.location
    resource_group_name   = each.value.resource_group_name
    workspace_resource_id = data.azurerm_log_analytics_workspace.law[each.key].id
    workspace_name        = data.azurerm_log_analytics_workspace.law[each.key].name
    tags                       = try(each.value.tags, null)
    plan {
        publisher       = each.value.plan.publisher
        product         = each.value.plan.product
        promotion_code  = try(each.value.plan.promotion_code, null)
    }

}