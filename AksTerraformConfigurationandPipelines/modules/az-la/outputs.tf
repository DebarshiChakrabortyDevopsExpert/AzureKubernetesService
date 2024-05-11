output "loganalytics_ids" {
    description = "Returns a map of loganalytics_ids key -> loganalytics_ids"
    depends_on  = [azurerm_log_analytics_workspace.log_analytics]
    value = {
        for group in keys(azurerm_log_analytics_workspace.log_analytics) :
        group => azurerm_log_analytics_workspace.log_analytics[group].id
    }
    sensitive = true
}